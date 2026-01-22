import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized Ad Service for managing Google AdMob Interstitial and Banner Ads
/// 
 /// - Frequency-based ad display (configurable save/export action count)
 /// - Premium user detection (no ads for premium users)
/// - App lifecycle awareness (no ads when app is backgrounded)
/// - Production-ready with test ad support for development
/// - Graceful error handling and fallback behavior
/// - Platform-specific ad unit IDs (Android & iOS)
class AdService with WidgetsBindingObserver {
  /// Frequency control: show ad after N successful save/export actions
  final int frequency;
  
  InterstitialAd? _interstitialAd;
  final List<BannerAd> _bannerAds = [];
  bool _isLoading = false;
  final bool _isBannerLoading = false;
  bool _isPremium = false;

  /// Tracks app lifecycle state (true when app is in foreground)
  bool _isForeground = true;
  String? _interstitialAdUnitId;
  String? _bannerAdUnitId;
  SharedPreferences? _prefs;
  
  /// Counter to track successful save/export actions
  int _count = 0;

  static const String _kCounterKey = 'ad_interstitial_count';
  
  // ======================= PRODUCTION AD UNIT IDs =======================
  /// Android Production Interstitial Ad Unit ID
  /// Provided by client: ca-app-pub-6262675977938420~1243842947 (App ID)
  static const String _kAndroidProdInterstitial =
      'ca-app-pub-6262675977938420/9260081685';
  
  /// iOS Production Interstitial Ad Unit ID
  /// Provided by client: ca-app-pub-6262675977938420~1557701540 (App ID)
  static const String _kIosProdInterstitial =
      'ca-app-pub-6262675977938420/2503101646';
  
  /// Android Production Banner Ad Unit ID
  static const String _kAndroidProdBanner =
      'ca-app-pub-6262675977938420/3471098903';
  
  /// iOS Production Banner Ad Unit ID
  static const String _kIosProdBanner =
      'ca-app-pub-6262675977938420/9523696635';
  
  // ======================= TEST AD UNIT IDs (for development) =======================
  /// Google AdMob Test Interstitial Ad Unit ID
  /// Use during development. Always test with test IDs first.
  static const String _kTestInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  
  /// Google AdMob Test Banner Ad Unit ID
  static const String _kTestBanner = 'ca-app-pub-3940256099942544/6300978111';

  /// Creates AdService instance
  /// 
  /// [frequency] - Number of save/export actions before showing interstitial ad
  ///               Default: 3 (show ad every 3 saves/exports)
  AdService({this.frequency = 3});

  /// Initializes the Ad Service
  /// 
  /// Must be called in main() before showing the app.
  /// This method:
  /// - Registers as app lifecycle observer
  /// - Initializes Google Mobile Ads SDK
  /// - Loads saved preferences (ad count, premium status)
  /// - Resolves appropriate ad unit IDs based on build mode
  /// - Preloads the first interstitial ad
  Future<void> initialize() async {
    try {
      WidgetsBinding.instance.addObserver(this);
      _prefs = await SharedPreferences.getInstance();
      _count = _prefs?.getInt(_kCounterKey) ?? 0;
      _isPremium = _prefs?.getBool('is_premium') ?? false;
      
      // Initialize Google Mobile Ads SDK
      await MobileAds.instance.initialize();
      _resolveAdUnitIds();
      preloadInterstitial();
      
      _logDebug('AdService initialized successfully. '
          'Premium: $_isPremium, Frequency: $frequency');
    } catch (e) {
      _logError('Error initializing AdService: $e');
    }
  }

  /// Resolves which ad unit IDs to use based on build mode and platform
  /// 
  /// Development mode: Uses Google's test ad unit IDs
  /// Production mode: Uses real ad unit IDs for the platform
  void _resolveAdUnitIds() {
    if (!kReleaseMode) {
      // Use test IDs in debug mode
      _interstitialAdUnitId = _kTestInterstitial;
      _bannerAdUnitId = _kTestBanner;
      _logDebug('Using TEST ad unit IDs (debug mode)');
      return;
    }
    
    // Use production IDs in release mode
    if (Platform.isAndroid) {
      _interstitialAdUnitId = _kAndroidProdInterstitial;
      _bannerAdUnitId = _kAndroidProdBanner;
      _logDebug('Using PRODUCTION Android ad unit IDs');
    } else if (Platform.isIOS) {
      _interstitialAdUnitId = _kIosProdInterstitial;
      _bannerAdUnitId = _kIosProdBanner;
      _logDebug('Using PRODUCTION iOS ad unit IDs');
    }
  }

  /// Updates premium status when user purchases subscription
  /// 
  /// Disables all ads immediately for premium users and saves status
  void setPremiumStatus(bool isPremium) {
    _isPremium = isPremium;
    _prefs?.setBool('is_premium', isPremium);
    
    // Cleanup banner ads for premium users
    if (isPremium) {
      for (var ad in _bannerAds) {
        ad.dispose();
      }
      _bannerAds.clear();
    }
    
    _logDebug('Premium status updated: $isPremium');
  }

  /// Preloads the interstitial ad in advance
  /// 
  /// Ads take time to load, so we load them before they're needed.
  /// This method skips loading if:
  /// - Already loading an ad
  /// - Ad is already loaded
  /// - Ad unit ID is not set
  /// - User is premium (no ads for premium users)
  void preloadInterstitial() {
    // Skip if already loading, already loaded, or premium
    if (_isLoading || 
        _interstitialAd != null || 
        _interstitialAdUnitId == null || 
        _isPremium) {
      return;
    }
    
    _isLoading = true;
    _logDebug('Preloading interstitial ad...');
    
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoading = false;
          _attachCallbacks(ad);
          _logDebug('✓ Interstitial ad loaded successfully');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isLoading = false;
          _logError('Failed to load interstitial ad: ${error.message}');
          // Gracefully handle failure - user can still use app
        },
      ),
    );
  }

  /// Loads a new banner ad for a specific screen
  /// 
  /// Each screen gets its own BannerAd instance to avoid
  /// "widget already in widget tree" errors when the same ad
  /// is displayed in multiple locations
  BannerAd? loadBannerAd() {
    if (_bannerAdUnitId == null || _isPremium) {
      return null;
    }
    
    _logDebug('Loading new banner ad instance...');
    
    final bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId!,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _logDebug('✓ Banner ad loaded successfully');
        },
        onAdFailedToLoad: (ad, LoadAdError error) {
          ad.dispose();
          _bannerAds.remove(ad);
          _logError('Failed to load banner ad: ${error.message}');
        },
      ),
    )..load();
    
    _bannerAds.add(bannerAd);
    return bannerAd;
  }

  /// Getter for checking if banner ads can be shown
  bool get hasBannerAd => _bannerAdUnitId != null && !_isPremium;

  /// Attaches full-screen content callbacks to handle ad lifecycle
  void _attachCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _logDebug('✓ Interstitial ad dismissed');
        ad.dispose();
        _interstitialAd = null;
        // Preload next ad for continuous experience
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _logError('Failed to show interstitial ad: $error');
        ad.dispose();
        _interstitialAd = null;
        // Try to preload next ad
        preloadInterstitial();
      },
      onAdShowedFullScreenContent: (ad) {
        _logDebug('→ Interstitial ad shown');
      },
    );
    ad.setImmersiveMode(true);
  }

  /// Called whenever a file is successfully saved or exported
  /// 
  /// Implements frequency-based ad display logic:
  /// 1. Increments save/export counter
  /// 2. When counter reaches frequency threshold, shows interstitial ad
  /// 3. Resets counter after ad is displayed
  /// 4. Ensures ad only shows when:
  ///    - Ad is preloaded and ready
  ///    - App is in foreground (visible to user)
  ///    - User is not premium
  /// 5. If ad not ready, preloads it for next time
  /// 
  /// **Policy Compliance:**
  /// - NOT showing ads on every action (configurable frequency)
  /// - Only showing when app is active (foreground check)
  /// - Gracefully handles ad failures (continues app flow)
  Future<void> onSuccessfulSaveOrExport() async {
    _prefs ??= await SharedPreferences.getInstance();
    
    // Premium users should never see ads
    if (_isPremium) {
      _logDebug('Ad skipped: User is premium');
      return;
    }
    
    // Increment counter
    _count = (_prefs?.getInt(_kCounterKey) ?? 0) + 1;
    _prefs?.setInt(_kCounterKey, _count);
    _logDebug('Save/Export action: $_count/$frequency');
    
    // Check if we've reached the frequency threshold
    if (_count >= frequency) {
      // Ad is ready and app is in foreground
      if (_interstitialAd != null && _isForeground) {
        _logDebug('Showing interstitial ad...');
        // Use addPostFrameCallback to ensure UI is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _interstitialAd?.show().then((_) {
            // Reset counter after successful display
            _prefs?.setInt(_kCounterKey, 0);
            _count = 0;
          }).catchError((e) {
            _logError('Error showing ad: $e');
            // Reset counter anyway to avoid showing ad indefinitely
            _prefs?.setInt(_kCounterKey, 0);
            _count = 0;
          });
        });
      } else {
        // Ad not ready or app in background
        if (!_isForeground) {
          _logDebug('Ad not shown: App is in background');
        } else {
          _logDebug('Ad not ready yet, preloading...');
          preloadInterstitial();
        }
      }
    }
  }

  /// Cleanup and resource disposal
  /// 
  /// Must be called when app is terminating or when you're done with ads.
  void dispose() {
    _logDebug('Disposing AdService resources...');
    _interstitialAd?.dispose();
    for (var ad in _bannerAds) {
      ad.dispose();
    }
    _bannerAds.clear();
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Tracks app lifecycle to prevent showing ads when app is backgrounded
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isForeground = state == AppLifecycleState.resumed;
    _logDebug('App lifecycle state: ${state.name} (foreground: $_isForeground)');
  }

  // ======================= DEBUG LOGGING =======================
  /// Logs debug messages during development
  void _logDebug(String message) {
    if (kDebugMode) {
      print('[AdService] 🔵 $message');
    }
  }

  /// Logs error messages
  void _logError(String message) {
    if (kDebugMode) {
      print('[AdService] 🔴 $message');
    }
  }

}               