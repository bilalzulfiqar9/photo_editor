# 🚀 Quick Start Guide - Google AdMob Integration

## 5-Minute Overview

Your app now has **fully integrated Google AdMob** ads. Here's what you need to know:

---

## ✅ What's Already Done

- ✅ AdService created and configured
- ✅ Android & iOS setup completed
- ✅ Test ads configured (safe for development)
- ✅ Production ads configured (real ad unit IDs)
- ✅ Premium user integration
- ✅ Frequency control (show ad every 3 saves)
- ✅ All documentation provided

**No further setup needed!**

---

## 🎮 How to Test

### 1. Run in Debug Mode (Test Ads)
```bash
flutter run
```
- Uses safe test ad unit IDs
- Won't violate AdMob policies
- Perfect for development

### 2. Run in Release Mode (Real Ads)
```bash
flutter run --release
```
- Uses production ad unit IDs
- Generates real revenue
- Use after app is published

### 3. Expected Behavior

After saving/exporting a file:
- Action 1: No ad (counter = 1)
- Action 2: No ad (counter = 2)
- Action 3: **AD SHOWN** ✓ (counter = 3, then resets)
- Action 4: No ad (counter = 1)
- ...and so on

---

## 📊 Customize Frequency

Want to change how often ads appear?

**File:** `lib/injection_container.dart` (around line 40)

```dart
// Current: Show ad every 3 saves
sl.registerLazySingleton(() => AdService(frequency: 3));

// Change to your preference:
sl.registerLazySingleton(() => AdService(frequency: 1));  // Every save
sl.registerLazySingleton(() => AdService(frequency: 5));  // Every 5 saves
sl.registerLazySingleton(() => AdService(frequency: 2));  // Every 2 saves
```

---

## 👤 Premium Users

When a user subscribes:
```dart
// Ads automatically disable
sl<AdService>().setPremiumStatus(true);
```

Ads won't show for premium subscribers ✓

---

## 🔍 View Debug Logs

When running in debug mode, you'll see logs like:
```
[AdService] 🔵 AdService initialized successfully
[AdService] 🔵 Preloading interstitial ad...
[AdService] ✓ Interstitial ad loaded successfully
```

These help you track what's happening with ads.

---

## 📱 Platform Ad Unit IDs

You don't need to change these - they're already correct!

### Android
- App ID: `ca-app-pub-6262675977938420~1243842947`
- Interstitial: `ca-app-pub-6262675977938420/9260081685`
- Banner: `ca-app-pub-6262675977938420/3471098903`

### iOS
- App ID: `ca-app-pub-6262675977938420~1557701540`
- Interstitial: `ca-app-pub-6262675977938420/2503101646`
- Banner: `ca-app-pub-6262675977938420/9523696635`

---

## 🎯 Key Files

### Main Service
- **`lib/core/ads/ad_service.dart`** - Controls everything

### Configuration
- **`lib/injection_container.dart`** - AdService setup
- **`android/app/src/main/AndroidManifest.xml`** - Android config
- **`ios/Runner/Info.plist`** - iOS config

### UI Components
- **`lib/core/presentation/widgets/banner_ad_widget.dart`** - Banner display
- **`lib/features/home/presentation/pages/home_page.dart`** - Home ads
- **`lib/features/home/presentation/pages/conversion_tools_screen.dart`** - Tool ads

---

## 📚 Documentation

For detailed information:

1. **`ADMOB_SETUP.md`** - Complete setup guide
2. **`ADMOB_IMPLEMENTATION_SUMMARY.md`** - Overview and features
3. **`ADMOB_VERIFICATION_CHECKLIST.md`** - Verification details
4. **`ADMOB_ARCHITECTURE.md`** - Technical deep dive

---

## 🐛 Troubleshooting

### Ads not showing?
1. Check app is in **foreground** (not backgrounded)
2. Verify **frequency threshold** reached (default: 3)
3. Ensure **internet connection** working
4. Check **build mode** matches ad unit IDs
5. Review **[AdService]** logs in console

### Check Build Mode
```bash
# Debug (test ads)
flutter run

# Release (production ads)
flutter run --release
```

### View Logs
Look for `[AdService]` messages in console output.

---

## ✨ Features You Have

### Interstitial Ads (Full-screen)
- Shows after file save/export
- Configurable frequency
- Automatically preloaded
- Ad dismissal handled gracefully

### Banner Ads (Bottom of screen)
- Passive revenue generation
- Shows on home screens
- Non-intrusive
- Respects premium status

### Premium Support
- Ads disable automatically
- User-friendly
- Works across sessions

### Automatic Switching
- Debug mode → Test ads
- Release mode → Production ads
- No manual configuration needed

---

## 🚀 Ready for App Store?

**Checklist before submitting:**

- [ ] Test with `flutter run --release`
- [ ] Verify ads show correctly
- [ ] Test on physical Android device
- [ ] Test on physical iOS device
- [ ] Check premium user flow
- [ ] Review AdMob policies (all good!)

---

## 📈 After Publishing

1. **Monitor** AdMob dashboard for impressions
2. **Check** revenue reports
3. **Adjust** frequency if needed
4. **Gather** user feedback
5. **Optimize** ad placements

---

## 💡 Pro Tips

1. **Frequency** - Higher frequency = more revenue but more annoying
2. **Testing** - Always test with release build before submitting
3. **Placement** - Banner ads are good for passive revenue
4. **Premium** - Offer premium to users who want ad-free
5. **Monitor** - Check AdMob weekly for performance

---

## 🆘 Need Help?

### Check These Files
- **Logs:** [AdService] in console
- **Code:** `lib/core/ads/ad_service.dart`
- **Config:** `lib/injection_container.dart`
- **Docs:** All ADMOB_*.md files

### Common Issues

**Q: Ads not showing after 3 saves**
A: Check if app is in foreground. Ads don't show when backgrounded.

**Q: Using test ads instead of real ads**
A: Run with `flutter run --release` for production ads.

**Q: Premium user still sees ads**
A: Call `setPremiumStatus(true)` when user subscribes.

**Q: Want to change ad frequency**
A: Edit `AdService(frequency: X)` in injection_container.dart

---

## 🎉 You're All Set!

Your app is **production-ready** for monetization.

Next steps:
1. Build and test
2. Publish to app stores
3. Monitor AdMob console
4. Adjust as needed

**Happy earning! 🚀📈**

---

**Questions?** Check the comprehensive documentation in:
- `ADMOB_SETUP.md`
- `ADMOB_ARCHITECTURE.md`
- Source code comments

---

*Last Updated: January 22, 2026*
*Status: Production Ready ✅*
