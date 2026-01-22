# Technical Architecture - Google AdMob Integration

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter App (main.dart)                   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           Dependency Injection (GetIt)               │  │
│  │      - Creates AdService singleton instance          │  │
│  │      - Registers all dependencies                    │  │
│  └──────────────────────────────────────────────────────┘  │
│                            │                                 │
│                            ▼                                 │
│  ┌──────────────────────────────────────────────────────┐  │
│  │            AdService (Core Service)                  │  │
│  │  ┌──────────────────────────────────────────────┐   │  │
│  │  │ Responsibilities:                            │   │  │
│  │  │ • Ad preloading & display                    │   │  │
│  │  │ • Frequency control logic                    │   │  │
│  │  │ • App lifecycle tracking                     │   │  │
│  │  │ • Premium user management                    │   │  │
│  │  │ • Platform detection (Android/iOS)           │   │  │
│  │  └──────────────────────────────────────────────┘   │  │
│  └──────────────────────────────────────────────────────┘  │
│              │                          │                   │
│              ▼                          ▼                   │
│  ┌──────────────────┐      ┌──────────────────┐            │
│  │ Google Mobile    │      │ SharedPreferences│            │
│  │ Ads SDK          │      │                  │            │
│  │                  │      │ Stores:          │            │
│  │ • Ad Loading     │      │ • Ad counter     │            │
│  │ • Ad Display     │      │ • Premium status │            │
│  │ • Ad Callbacks   │      └──────────────────┘            │
│  └──────────────────┘                                       │
│              │                                              │
│              ▼                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │          Google AdMob Backend (Cloud)                │  │
│  │  ┌──────────────┐              ┌──────────────┐     │  │
│  │  │   Android    │              │     iOS      │     │  │
│  │  │ Ad Unit IDs  │              │ Ad Unit IDs  │     │  │
│  │  │              │              │              │     │  │
│  │  │ Interstitial │              │ Interstitial │     │  │
│  │  │ Banner       │              │ Banner       │     │  │
│  │  └──────────────┘              └──────────────┘     │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Data Flow

### 1. Initialization Flow

```
main()
  │
  ├─ WidgetsFlutterBinding.ensureInitialized()
  │
  ├─ di.init() ────┐
  │                │
  │    ┌───────────▼────────────────┐
  │    │ injection_container.dart    │
  │    │                            │
  │    │ • Register AdService       │
  │    │ • Register PaymentCubit    │
  │    │ • Register other services  │
  │    └────────────┬───────────────┘
  │                │
  │    ┌───────────▼────────────────────┐
  │    │ AdService.initialize()         │
  │    │                                │
  │    │ 1. addObserver(lifecycle)      │
  │    │ 2. Load SharedPreferences      │
  │    │ 3. Initialize MobileAds SDK    │
  │    │ 4. Resolve ad unit IDs         │
  │    │ 5. preloadInterstitial()       │
  │    └──────────────────────────────┘
  │
  └─ runApp(MyApp())
```

### 2. Ad Display Flow

```
User Action: Save/Export File
  │
  ├─ File saved successfully
  │
  ├─ Call: adService.onSuccessfulSaveOrExport()
  │
  ├─ Load preferences from SharedPreferences
  │
  ├─ Check: Is user premium?
  │  ├─ YES → Return (no ads)
  │  └─ NO → Continue
  │
  ├─ Increment counter: counter++
  │
  ├─ Save counter to SharedPreferences
  │
  ├─ Check: counter >= frequency?
  │  ├─ NO → Wait for next action
  │  └─ YES → Continue
  │
  ├─ Check: Is ad loaded & ready?
  │  ├─ NO → Preload ad, return
  │  └─ YES → Continue
  │
  ├─ Check: Is app in foreground?
  │  ├─ NO → Don't show ad, return
  │  └─ YES → Continue
  │
  ├─ Schedule ad display:
  │  └─ addPostFrameCallback(() { ad.show() })
  │
  ├─ Reset counter to 0
  │
  ├─ User sees Full-Screen Interstitial Ad
  │
  └─ onAdDismissed() callback
     │
     ├─ Dispose of shown ad
     ├─ Set _interstitialAd = null
     └─ preloadInterstitial() (next ad)
```

### 3. Premium Status Update Flow

```
User Purchases Subscription
  │
  ├─ InAppPurchase completes
  │
  ├─ IAPService.onPurchaseSuccess() callback
  │
  ├─ PaymentRepository.setPremiumStatus(true)
  │  └─ SharedPreferences.setBool('is_premium', true)
  │
  ├─ AdService.setPremiumStatus(true)
  │  │
  │  ├─ Set _isPremium = true
  │  ├─ Save to SharedPreferences
  │  ├─ Dispose banner ad
  │  └─ Prevent future ad loading
  │
  └─ All ads disabled immediately
```

---

## Class Responsibilities

### AdService Class

```dart
class AdService with WidgetsBindingObserver {
  
  // ==================== STATE ====================
  final int frequency              // Ad frequency (saves between ads)
  InterstitialAd? _interstitialAd  // Loaded interstitial ad
  BannerAd? _bannerAd              // Loaded banner ad
  bool _isLoading                  // Ad loading state
  bool _isBannerLoading            // Banner loading state
  bool _isPremium                  // Premium user flag
  bool _isForeground               // App foreground state
  String? _interstitialAdUnitId    // Resolved ad unit ID
  String? _bannerAdUnitId          // Resolved banner unit ID
  SharedPreferences? _prefs        // Saved preferences
  int _count                       // Save/export action counter

  // ==================== LIFECYCLE ====================
  Future<void> initialize()        // Initialize SDK & preload ads
  void dispose()                   // Cleanup resources

  // ==================== AD LOADING ====================
  void preloadInterstitial()       // Preload interstitial ad
  void loadBannerAd()              // Preload banner ad
  void _attachCallbacks()          // Setup ad callbacks

  // ==================== AD DISPLAY ====================
  Future<void> onSuccessfulSaveOrExport()  // Triggered after save/export
  void _resolveAdUnitIds()         // Choose test or production IDs

  // ==================== USER MANAGEMENT ====================
  void setPremiumStatus(bool)      // Update premium status
  void didChangeAppLifecycleState()// Track app lifecycle

  // ==================== UTILITIES ====================
  void _logDebug(String)           // Debug logging
  void _logError(String)           // Error logging
}
```

---

## State Machine

### Ad Loading States

```
┌─────────────┐
│   Initial   │
└──────┬──────┘
       │
       │ initialize()
       │ preloadInterstitial()
       │
       ▼
┌─────────────────┐
│   Loading...    │ (_isLoading = true)
└────────┬────────┘
         │
    ┌────┴─────────────┐
    │                  │
    ▼                  ▼
┌─────────┐    ┌──────────────┐
│ Loaded  │    │ Failed       │
│ (_isLoading) │ (_isLoading  │
└────┬────┘    │  = false)    │
     │         └──────┬───────┘
     │                │
     │                └─────┐
     │                      │
     │                ┌─────▼─────┐
     │                │ Preloading│
     │                │   Again   │
     │                └───────────┘
     │
     └─────┬─────────────┐
           │             │
     ┌─────▼─────┐   ┌───▼──────┐
     │ Shown     │   │ Disposed │
     │ (on show  │   │ (after   │
     │  request) │   │  display)│
     └───────────┘   └──────────┘
```

### Frequency Counter States

```
┌─────────────────────────────────────┐
│  Counter = 0 (reset after display)  │
└──────────────┬──────────────────────┘
               │ Save/Export action
               │
┌──────────────▼──────────────────────┐
│  Counter = 1                        │
│  (< frequency, no ad shown)         │
└──────────────┬──────────────────────┘
               │ Save/Export action
               │
┌──────────────▼──────────────────────┐
│  Counter = 2                        │
│  (< frequency, no ad shown)         │
└──────────────┬──────────────────────┘
               │ Save/Export action
               │
┌──────────────▼──────────────────────┐
│  Counter = 3 (== frequency)         │
│  ✓ AD SHOWN (if ready & foreground) │
└──────────────┬──────────────────────┘
               │ Reset
               │
               └─ Return to Counter = 0
```

---

## Sequence Diagrams

### Ad Loading Sequence

```
AdService           GoogleMobileAds      AdMob Cloud
    │                    │                   │
    │─ preloadInterstitial()                │
    │                    │                   │
    │─ InterstitialAd.load()────────────────►
    │                    │                   │
    │                    │◄────Ad Loaded────│
    │                    │                   │
    │◄─ onAdLoaded()─────│                   │
    │                    │                   │
    │─ _attachCallbacks()                   │
    │                    │                   │
    (Ad ready for display)                  │
```

### Ad Display Sequence

```
User              AdService           GoogleMobileAds    AdMob Backend
 │                    │                     │                  │
 │─ Save File────────►│                     │                  │
 │                    │                     │                  │
 │                    │─ Check frequency    │                  │
 │                    │─ Check foreground   │                  │
 │                    │                     │                  │
 │                    │─ ad.show()─────────►│                  │
 │                    │                     │                  │
 │◄───────────────Full Screen Ad────────────│◄───Send Ad────────
 │                    │                     │                  │
 │─ (Watch Ad)───────►│                     │                  │
 │                    │                     │                  │
 │─ Close/Dismiss────►│                     │                  │
 │                    │                     │                  │
 │                    │─ onAdDismissed()────────────────────────►
 │                    │                     │                  │
 │                    │─ Dispose ad         │                  │
 │                    │─ Reset counter      │                  │
 │                    │─ Preload next       │                  │
 │                    │                     │                  │
 └─ Continue using app
```

---

## Configuration Resolution Logic

```dart
void _resolveAdUnitIds() {
  if (!kReleaseMode) {
    // Debug mode - use test IDs
    _interstitialAdUnitId = TEST_INTERSTITIAL_ID;
    _bannerAdUnitId = TEST_BANNER_ID;
    return;
  }
  
  // Release mode - use production IDs
  if (Platform.isAndroid) {
    _interstitialAdUnitId = ANDROID_PROD_INTERSTITIAL_ID;
    _bannerAdUnitId = ANDROID_PROD_BANNER_ID;
  } else if (Platform.isIOS) {
    _interstitialAdUnitId = IOS_PROD_INTERSTITIAL_ID;
    _bannerAdUnitId = IOS_PROD_BANNER_ID;
  }
}
```

### Build Mode Detection

| Scenario | kReleaseMode | Ad Unit IDs |
|----------|-------------|-------------|
| `flutter run` | false | Test IDs |
| `flutter run --debug` | false | Test IDs |
| `flutter run --release` | true | Production IDs |
| `flutter build apk` | true | Production IDs |
| `flutter build ios` | true | Production IDs |

---

## Event Handling

### Lifecycle Events

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  switch (state) {
    case AppLifecycleState.paused:    // App backgrounded
      _isForeground = false;
      // Don't show ads
      break;
    case AppLifecycleState.resumed:   // App foregrounded
      _isForeground = true;
      // Can show ads
      break;
    case AppLifecycleState.detached:
    case AppLifecycleState.hidden:
      _isForeground = false;
      break;
    case AppLifecycleState.inactive:
      break;
  }
}
```

### Ad Callbacks

```dart
void _attachCallbacks(InterstitialAd ad) {
  ad.fullScreenContentCallback = FullScreenContentCallback(
    
    onAdShowedFullScreenContent: (ad) {
      // Ad displayed to user
      _logDebug('Ad shown');
    },
    
    onAdDismissedFullScreenContent: (ad) {
      // User closed ad
      ad.dispose();
      _interstitialAd = null;
      preloadInterstitial(); // Load next
    },
    
    onAdFailedToShowFullScreenContent: (ad, error) {
      // Ad failed to display
      ad.dispose();
      _interstitialAd = null;
      preloadInterstitial(); // Try next
    },
  );
}
```

---

## Persistence Layer

### SharedPreferences Keys

```dart
// Ad counter
Key: 'ad_interstitial_count'
Type: int
Persists: Counter value between sessions

// Premium status
Key: 'is_premium'
Type: bool
Persists: Premium subscription status
```

### Data Flow

```
┌─────────────────────┐
│  AdService (_count) │
└──────────┬──────────┘
           │ onSuccessfulSaveOrExport()
           │
┌──────────▼──────────────────────┐
│ SharedPreferences.setInt()       │
│ ('ad_interstitial_count', count) │
└──────────┬──────────────────────┘
           │
┌──────────▼──────────────────────┐
│ Stored on Device                 │
│ (Persists across app restarts)   │
└──────────┬──────────────────────┘
           │ App restart
           │
┌──────────▼──────────────────────┐
│ initialize()                     │
│ _count = prefs.getInt(...)       │
└──────────┬──────────────────────┘
           │
┌──────────▼──────────────────────┐
│  AdService restored with        │
│  previous counter value         │
└──────────────────────────────────┘
```

---

## Error Handling Strategy

### Try-Catch Block

```dart
Future<void> initialize() async {
  try {
    // All initialization code
    WidgetsBinding.instance.addObserver(this);
    _prefs = await SharedPreferences.getInstance();
    await MobileAds.instance.initialize();
    _resolveAdUnitIds();
    preloadInterstitial();
    
  } catch (e) {
    // Graceful failure - log and continue
    _logError('Error initializing AdService: $e');
    // App still works without ads
  }
}
```

### Callback Error Handling

```dart
_interstitialAd?.show().then((_) {
  // Ad shown successfully
  _prefs?.setInt(_kCounterKey, 0);
  _count = 0;
}).catchError((e) {
  // Ad failed to show
  _logError('Error showing ad: $e');
  // Still reset counter to avoid infinite loop
  _prefs?.setInt(_kCounterKey, 0);
  _count = 0;
});
```

---

## Thread Safety

### Main Thread Considerations

```dart
// Safe: addPostFrameCallback ensures main thread
WidgetsBinding.instance.addPostFrameCallback((_) {
  _interstitialAd?.show();
});

// Safe: setInt is thread-safe for SharedPreferences
_prefs?.setInt(_kCounterKey, _count);

// Safe: Ad callbacks execute on main thread
InterstitialAd.load(...)
```

---

## Memory Management

### Resource Cleanup

```dart
void dispose() {
  // Dispose ads (release memory)
  _interstitialAd?.dispose();
  _bannerAd?.dispose();
  
  // Unregister observer (remove reference)
  WidgetsBinding.instance.removeObserver(this);
  
  // App can be garbage collected
}
```

### Ad Instance Management

```
Only ONE InterstitialAd instance at a time:

Loaded Ad → Show → Dispose → Next Ad
            │      │
            └──────┘
         (single instance)

Never:
Loaded Ad1
Loaded Ad2 (while Ad1 still exists) ← PREVENTS THIS
```

---

## Summary

This architecture provides:
- ✅ Clean separation of concerns
- ✅ Centralized ad management
- ✅ Efficient resource usage
- ✅ Graceful error handling
- ✅ Platform independence
- ✅ Easy testing and maintenance
- ✅ Production-ready reliability

---

**Document Version:** 1.0
**Date:** January 22, 2026
**Status:** Production Ready
