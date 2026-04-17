# 🚀 AgriFlow Play Store Publishing Guide

This guide walks you through publishing AgriFlow to the Google Play Store.

---

## 📋 Prerequisites Checklist

- [ ] Google Play Developer Account ($25 one-time registration fee)
- [ ] Java JDK installed (for keytool)
- [ ] Flutter SDK installed and configured
- [ ] Android SDK/build tools installed

---

## 🔐 Step 1: Generate Upload Keystore

**IMPORTANT**: This keystore is CRITICAL. Back it up safely. Without it, you CANNOT update your app.

### Option A: Use the automated script
```powershell
.\generate-keystore.ps1
```

### Option B: Manual generation
```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks -storetype JKS `
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload `
  -storepass changeit -keypass changeit `
  -dname "CN=AgriFlow, OU=Development, O=Farm, L=City, S=State, C=IN"
```

### Update credentials
Edit `android/key.properties` with your actual passwords:
```properties
storePassword=your_secure_password
keyPassword=your_key_password
keyAlias=upload
storeFile=../app/upload-keystore.jks
```

### 🔒 Security Best Practices
1. **NEVER** commit the keystore to version control
2. Add to `.gitignore`:
   ```
   **/*.jks
   **/*.keystore
   android/key.properties
   ```
3. Backup the keystore to multiple secure locations
4. Remember your passwords - recovery is impossible if lost

---

## 🏗️ Step 2: Configure App for Release

### Update app version
In `pubspec.yaml`:
```yaml
version: 1.0.0+1  # Format: versionName+versionCode
```
- Increment `versionCode` (the +1 part) for each release
- Change `versionName` (1.0.0) for your marketing version

### App icon
The app icon is already configured in `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  image_path: "assets/images/icon.png"
```

Generate icons:
```bash
flutter pub run flutter_launcher_icons
```

---

## 📦 Step 3: Build the App Bundle

### Option A: Use the build script
```powershell
.\build-release.ps1
```

### Option B: Manual build
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

The output will be at:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## 🎯 Step 4: Create Play Store Listing

### 4.1 Access Play Console
1. Go to https://play.google.com/console
2. Sign in with your Google Developer account
3. Accept the developer agreement if prompted

### 4.2 Create Your App
1. Click **"Create app"**
2. Fill in:
   - **App name**: AgriFlow
   - **Default language**: English (US)
   - **App or game**: App
   - **Free or paid**: Free
3. Accept the declarations
4. Click **"Create app"**

### 4.3 Store Listing Setup

#### App Information
- **App name**: AgriFlow
- **Short description** (80 chars):
  ```
  Tamil Nadu's premier agricultural marketplace for farmers and buyers
  ```

- **Full description** (4000 chars):
  ```
  AgriFlow - Connecting Tamil Nadu's Farmers with Markets

  AgriFlow is a comprehensive agricultural marketplace app designed specifically for Tamil Nadu farmers. Buy, sell, and trade agricultural products directly with buyers.

  KEY FEATURES:

  🌾 Marketplace
  • Browse agricultural products
  • List your produce for sale
  • Direct farmer-to-buyer communication
  • Fair pricing and transparent deals

  📍 Location-Based Services
  • Find nearby markets and buyers
  • GPS-enabled location services
  • Regional market price information

  💬 Communication
  • Chat with buyers and sellers
  • Negotiate prices directly
  • Build agricultural community connections

  📊 Crop Management
  • Track your listings
  • Manage inventory
  • Monitor sales and transactions

  🌤️ Weather & Information
  • Local weather forecasts
  • Agricultural tips and advice
  • Market price updates

  Perfect for:
  • Farmers in Tamil Nadu
  • Agricultural traders
  • Farm equipment buyers
  • Organic produce sellers

  Download AgriFlow today and connect with Tamil Nadu's growing agricultural community!

  Support: support@agriflow.com
  Privacy Policy: https://agriflow.com/privacy
  ```

#### Graphics Requirements

**Screenshots** (minimum 2, maximum 8 per device type):
- Phone screenshots (16:9 or 9:16 ratio)
  - Recommended: 1080 x 1920 px
  - Take 4-6 screenshots showing key features:
    1. Home screen with marketplace
    2. Product listing page
    3. Product detail view
    4. Map/location feature
    5. User profile/dashboard
    6. Chat/communication feature

**App Icon**:
- Format: 32-bit PNG with alpha
- Size: 512 x 512 pixels
- Max file size: 1 MB
- Already generated from `assets/images/icon.png`

**Feature Graphic**:
- Format: PNG or JPEG (no alpha)
- Size: 1024 x 500 pixels
- This appears in Play Store browsing

**App Category**:
- Category: Shopping or Business

**Contact Details**:
- Developer email: your-email@domain.com
- Website: https://agriflow.com (if available)
- Privacy policy URL: Required for production

---

## 📝 Step 5: Content Rating

Complete the content rating questionnaire:
1. Go to **"Store presence"** > **"Content rating"**
2. Answer the questionnaire honestly about your app's content
3. Submit to receive your IARC rating

---

## 🎨 Step 6: Privacy Policy

Create a privacy policy page (required for Play Store):

1. Host it on a website (e.g., https://agriflow.com/privacy)
2. Include:
   - What data you collect
   - How you use the data
   - Third-party services used (Google Maps, analytics, etc.)
   - User rights and choices
   - Contact information

---

## 🚀 Step 7: Upload Your App Bundle

### 7.1 Initial Release
1. Go to **"Production"** or **"Internal testing"**
2. Click **"Create new release"**
3. Upload `app-release.aab` from:
   ```
   build/app/outputs/bundle/release/app-release.aab
   ```
4. Fill in release notes:
   ```
   Initial release of AgriFlow - Tamil Nadu Agricultural Marketplace
   
   Features:
   • Browse and list agricultural products
   • Location-based marketplace
   • Direct farmer-to-buyer communication
   • Weather and market information
   ```

### 7.2 Review and Publish
1. Review all store listing details
2. Check for any policy warnings
3. Click **"Review release"**
4. Address any issues that arise
5. Click **"Start rollout to Production"** (or Internal testing)

---

## ✅ Step 8: Pre-Launch Checklist

- [ ] App bundle uploaded successfully
- [ ] Store listing complete (descriptions, screenshots, graphics)
- [ ] Content rating completed
- [ ] Privacy policy URL added
- [ ] Contact details provided
- [ ] App category selected
- [ **CRITICAL** ] Keystore backed up securely
- [ ] Tested on physical devices
- [ ] No crashes or major bugs
- [ ] All features working

---

## 🔄 Future Updates

When releasing updates:

1. **Increment version** in `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # Increment the +2 part
   ```

2. **Build new app bundle**:
   ```bash
   .\build-release.ps1
   ```

3. **Upload to Play Console**:
   - Go to Production > Create new release
   - Upload the new .aab file
   - Add release notes
   - Roll out to production

**⚠️ CRITICAL**: Always use the SAME keystore for all updates. If you lose it, you cannot update your app.

---

## 💡 Pro Tips

1. **Start with Internal Testing**: Release to a small group first
2. **Monitor Crashes**: Use Play Console's Android Vitals
3. **Respond to Reviews**: Engage with user feedback
4. **Regular Updates**: Keep the app fresh with new features
5. **A/B Testing**: Test different store listings
6. **Analytics**: Track downloads and user engagement

---

## 🆘 Troubleshooting

### Build fails
- Run `flutter clean` and `flutter pub get`
- Check that keystore path in `key.properties` is correct
- Ensure Java is in your PATH

### Upload rejected
- Verify the app bundle is signed correctly
- Check Play Console for specific error messages
- Ensure version code is incremented for updates

### App crashes on startup
- Test with `flutter run --release` before uploading
- Check logcat for error messages
- Verify all dependencies are included

---

## 📞 Support Resources

- **Flutter Docs**: https://flutter.dev/docs/deployment/android
- **Play Console Help**: https://support.google.com/googleplay/android-developer
- **App Bundle Guide**: https://developer.android.com/studio/publish/app-signing

---

*Good luck with your Play Store launch! 🚀*
