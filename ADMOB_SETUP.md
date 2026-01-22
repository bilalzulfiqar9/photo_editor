# Google AdMob Integration - Production Implementation Guide

## Overview
This document details the complete Google AdMob integration for Screen Stitch Flutter application with Interstitial and Banner ad support for both Android and iOS platforms.

## ✅ Implementation Status

### Completed Features
- ✅ Frequency-based interstitial ad display (configurable)
- ✅ Ad preloading before display for seamless UX
- ✅ Premium user detection (no ads for premium users)
- ✅ App lifecycle awareness (no ads when backgrounded)
- ✅ Platform-specific ad unit IDs (Android & iOS)
- ✅ Test ad support for development
- ✅ Production ad unit IDs for release builds
- ✅ Banner ads for additional revenue
- ✅ Comprehensive error handling and logging
- ✅ Google AdMob policy compliance

---

## 📱 Platform Configuration

### Android Configuration

#### AdMob App ID
```
ca-app-pub-6262675977938420~1243842947
```

#### Ad Unit IDs
| Ad Type | Ad Unit ID |
|---------|-----------|
| Interstitial | `ca-app-pub-6262675977938420/9260081685` |
| Banner | `ca-app-pub-6262675977938420/3471098903` |

#### Configuration File
**Location:** `android/app/src/main/AndroidManifest.xml`

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-6262675977938420~1243842947"/>
```

**Status:** ✅ Already configured

---

### iOS Configuration

#### AdMob App ID
```
ca-app-pub-6262675977938420~1557701540
```

#### Ad Unit IDs
| Ad Type | Ad Unit ID |
|---------|-----------|
| Interstitial | `ca-app-pub-6262675977938420/2503101646` |
| Banner | `ca-app-pub-6262675977938420/9523696635` |

#### Configuration File
**Location:** `ios/Runner/Info.plist`

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-6262675977938420~1557701540</string>
```

**Status:** ✅ Already configured

---

## 🚀 Implementation Details

### Core Service: AdService
**Location:** `lib/core/ads/ad_service.dart`

#### Key Responsibilities
1. **Initialization** - Initializes Google Mobile Ads SDK
2. **Ad Loading** - Preloads ads before they're needed
3. **Ad Display** - Shows ads based on frequency control
4. **Lifecycle Management** - Respects app lifecycle
5. **Premium Support** - Disables ads for premium users

#### Constructor
```dart
AdService({this.frequency = 3})
```
- `frequency` - Show ad after N save/export actions (default: 3)

#### Main Methods

##### `initialize()` - Must be called in main()
```dart
await AdService().initialize();
```
- Initializes Google Mobile Ads SDK
- Loads user preferences
- Resolves ad unit IDs based on build mode
- Preloads first ad

##### `onSuccessfulSaveOrExport()` - Called after file save/export
```dart
await adService.onSuccessfulSaveOrExport();
```
- Increments action counter
- Shows ad when threshold is reached
- Respects premium status
- Ensures app is in foreground

##### `setPremiumStatus(bool)` - Called when user subscribes
```dart
adService.setPremiumStatus(true);
```
- Disables all ads immediately
- Disposes loaded ads
- Persists status to preferences

##### `dispose()` - Called on app exit
```dart
adService.dispose();
```
- Disposes ad resources
- Removes lifecycle observer

---

## 📊 Frequency Control Logic

### How It Works
1. Counter starts at 0
2. Each successful save/export increments counter
3. When counter reaches `frequency` (default: 3):
   - **IF** ad is ready AND app is foreground → show ad
   - **ELSE** → preload ad for next time
4. Counter resets after ad display

### Example Timeline (frequency = 3)
```
Action 1: counter = 1 → no ad shown
Action 2: counter = 2 → no ad shown
Action 3: counter = 3 → ✓ AD SHOWN (if ready & foreground)
Action 4: counter = 1 → no ad shown
Action 5: counter = 2 → no ad shown
Action 6: counter = 3 → ✓ AD SHOWN (if ready & foreground)
```

### Customizing Frequency
Change the frequency when creating AdService:

```dart
// Show ad after every save
sl.registerLazySingleton(() => AdService(frequency: 1));

// Show ad after every 5 saves
sl.registerLazySingleton(() => AdService(frequency: 5));

// Default: 3 saves
sl.registerLazySingleton(() => AdService(frequency: 3));
```

**Location:** `lib/injection_container.dart` (line ~40)

---

## 🧪 Development vs Production

### Development Mode (Debug)
- Uses **Google's test ad unit IDs**
- Won't trigger AdMob violation policies
- Safe for testing

```
Interstitial: ca-app-pub-3940256099942544/1033173712
Banner: ca-app-pub-3940256099942544/6300978111
```

### Production Mode (Release)
- Uses **real ad unit IDs** (configured above)
- Generates revenue
- Requires app to be published on Play Store / App Store

**Automatic switching:** AdService detects build mode automatically using `kReleaseMode`

---

## 📍 Integration Points

### 1. Main Application Initialization
**Location:** `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // ← Initializes AdService here
  runApp(const MyApp());
}
```

### 2. Dependency Injection Setup
**Location:** `lib/injection_container.dart`

```dart
sl.registerLazySingleton(() => AdService(frequency: 3));
// ... later ...
await sl<AdService>().initialize();
```

### 3. Call After Save/Export
**Locations where implemented:**
- `lib/core/utils/gallery_saver_helper.dart`
- `lib/features/pdf_tools/presentation/pages/image_to_pdf_screen.dart`

```dart
await sl<AdService>().onSuccessfulSaveOrExport();
```

### 4. Premium User Support
**Location:** `lib/injection_container.dart`

When user purchases subscription:
```dart
onPurchaseSuccess: (purchaseDetails) {
  sl<PaymentRepository>().setPremiumStatus(true);
  sl<AdService>().setPremiumStatus(true); // ← Disables ads
}
```

### 5. Banner Ads (Optional)
**Locations:**
- `lib/features/home/presentation/pages/home_page.dart`
- `lib/features/home/presentation/pages/conversion_tools_screen.dart`

```dart
@override
void initState() {
  super.initState();
  _adService = sl<AdService>();
  _adService.loadBannerAd(); // ← Load banner ad
}
```

---

## 🛡️ Google AdMob Policy Compliance

### ✅ What We're Doing Right
1. **Frequency Control** - Not showing ads on every action
2. **Foreground Check** - Never showing ads when app is backgrounded
3. **Ready Check** - Only showing ads when fully loaded
4. **Premium Option** - Users can opt-out by purchasing premium
5. **Error Handling** - Gracefully handling ad failures
6. **Test Ads** - Using test ads during development

### ⚠️ Important Compliance Notes
- **NEVER** modify ad unit IDs or use other developers' IDs
- **NEVER** show multiple ads simultaneously
- **NEVER** force users to click ads
- **NEVER** hide important app functionality behind ads
- **DO** test thoroughly before release
- **DO** monitor ad revenue in AdMob console
- **DO** respect user privacy settings

---

## 🐛 Debugging

### Enable Logging
Logs are printed to console during development with `[AdService]` prefix:

```
[AdService] 🔵 AdService initialized successfully
[AdService] 🔵 Using TEST ad unit IDs (debug mode)
[AdService] 🔵 Preloading interstitial ad...
[AdService] ✓ Interstitial ad loaded successfully
[AdService] → Interstitial ad shown
[AdService] ✓ Interstitial ad dismissed
```

### Common Issues

#### Ads not showing
1. **Check Build Mode**
   ```bash
   flutter run --release  # Use release mode with production IDs
   ```
2. **Check Ad Unit IDs**
   - Verify correct IDs in AdService.dart
   - Ensure IDs match your AdMob account

3. **Check Internet Connection**
   - Ads require internet to load
   - Device must have working internet

4. **Check User Status**
   ```dart
   bool isPremium = await repository.isUserPremium();
   // Premium users don't see ads
   ```

#### Ad loaded but not shown
1. **Foreground Check** - Ensure app is active
2. **Ad Ready Check** - Ad may still be loading
3. **Frequency Check** - Action counter may not have reached threshold

#### Test Ads not appearing
1. Use correct test ad unit IDs (provided above)
2. Ensure build mode is Debug (`kReleaseMode = false`)
3. Check network connectivity

---

## 📈 Testing Checklist

Before releasing to Play Store / App Store:

- [ ] Test with **real ad unit IDs** in release build
- [ ] Verify interstitial ads show after N saves
- [ ] Verify banner ads show on home screens
- [ ] Test premium user (no ads should appear)
- [ ] Test app lifecycle (ads not shown when backgrounded)
- [ ] Test ad dismissal (counter resets, next ad preloads)
- [ ] Test ad failures (app continues to work)
- [ ] Monitor AdMob console for ad impressions
- [ ] Verify correct platform IDs (Android & iOS)
- [ ] Check policy violations in AdMob dashboard

---

## 📞 Support Resources

### Official Documentation
- [Google Mobile Ads SDK for Flutter](https://pub.dev/packages/google_mobile_ads)
- [Google AdMob Help](https://support.google.com/admob)
- [AdMob Policies](https://support.google.com/admob/answer/6128543)

### Troubleshooting
- Check [pub.dev issues](https://github.com/googleads/googleads-mobile-flutter/issues)
- Review AdMob account settings
- Verify app configuration in AdMob console

---

## 🔄 Version Information

- **google_mobile_ads:** 7.0.0
- **Flutter SDK:** Compatible with Flutter 3.0+
- **Minimum Android SDK:** 21
- **Minimum iOS:** 11.0

---

## Summary

The Google AdMob integration is **production-ready** with:
- Configurable frequency control
- Full platform support (Android & iOS)
- Premium user detection
- Comprehensive error handling
- Complete policy compliance
- Development and production modes
- Banner ad support

**Next Steps:**
1. Test thoroughly with release builds
2. Monitor ad performance in AdMob console
3. Adjust frequency if needed
4. Release to app stores when satisfied
