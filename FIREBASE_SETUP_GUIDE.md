# Firebase Setup Guide for iTraceLink
**Estimated Time: 10-15 minutes**

This guide will walk you through setting up Firebase for the iTraceLink mobile app. Follow each step carefully.

---

## Prerequisites

✅ Google Account (Gmail)
✅ Flutter SDK installed on your computer
✅ This project cloned to your computer

---

## Step 1: Create Firebase Project (3 minutes)

### 1.1 Go to Firebase Console
1. Open your browser and go to: **https://console.firebase.google.com/**
2. Click **"Add project"** or **"Create a project"**

### 1.2 Create the Project
1. **Project name**: Enter `iTraceLink` (or any name you prefer)
2. Click **Continue**

### 1.3 Google Analytics (Optional)
1. You can **disable** Google Analytics for now (not required)
2. Or enable it if you want analytics (recommended)
3. Click **Create project**
4. Wait for the project to be created (30 seconds)
5. Click **Continue** when done

---

## Step 2: Enable Firebase Services (5 minutes)

### 2.1 Enable Authentication

1. In the left sidebar, click **"Build"** → **"Authentication"**
2. Click **"Get started"**
3. Go to **"Sign-in method"** tab
4. Enable **"Email/Password"**:
   - Click on "Email/Password"
   - Toggle **Enable**
   - Click **Save**
5. Enable **"Phone"**:
   - Click on "Phone"
   - Toggle **Enable**
   - Click **Save**

### 2.2 Create Firestore Database

1. In the left sidebar, click **"Build"** → **"Firestore Database"**
2. Click **"Create database"**
3. Choose **"Start in production mode"** (we'll add security rules later)
4. Click **Next**
5. Select location: **"us-central1"** (or closest to Rwanda if available)
6. Click **Enable**
7. Wait for database to be created (1-2 minutes)

### 2.3 Enable Storage

1. In the left sidebar, click **"Build"** → **"Storage"**
2. Click **"Get started"**
3. Click **"Next"** (default security rules)
4. Select same location as Firestore: **"us-central1"**
5. Click **Done**

### 2.4 Enable Cloud Messaging

1. In the left sidebar, click **"Build"** → **"Cloud Messaging"**
2. (This is usually already enabled, nothing to do here)

---

## Step 3: Install FlutterFire CLI (2 minutes)

### 3.1 Open Terminal/Command Prompt

**On Windows:**
- Press `Win + R`, type `cmd`, press Enter

**On Mac/Linux:**
- Open Terminal

### 3.2 Install FlutterFire CLI

Run this command:
```bash
dart pub global activate flutterfire_cli
```

Wait for installation to complete (1-2 minutes).

### 3.3 Login to Firebase

Run this command:
```bash
firebase login
```

- A browser window will open
- Select your Google account
- Click **"Allow"**
- Return to terminal

---

## Step 4: Configure Your Flutter App (3 minutes)

### 4.1 Navigate to Your Project

In terminal/command prompt, navigate to your iTraceLink project:

```bash
cd path/to/itrace-Link
```

For example:
- Windows: `cd C:\Users\YourName\Projects\itrace-Link`
- Mac/Linux: `cd ~/Projects/itrace-Link`

### 4.2 Run FlutterFire Configure

Run this command:
```bash
flutterfire configure
```

You'll see several prompts:

**1. Select Firebase project:**
- Use arrow keys to select `iTraceLink` (the project you just created)
- Press Enter

**2. Which platforms should your configuration support?**
- Press Space to select **Android**
- Press Space to select **iOS** (if you have a Mac)
- Press Enter

**3. The tool will now configure your project...**
- Wait for it to complete (1-2 minutes)
- You'll see: ✓ Firebase configuration complete!

### 4.3 What Just Happened?

The FlutterFire CLI just created/updated these files:
- ✅ `lib/firebase_options.dart` - Your Firebase configuration
- ✅ `android/app/google-services.json` - Android configuration
- ✅ `ios/Runner/GoogleService-Info.plist` - iOS configuration (if on Mac)

---

## Step 5: Add Firestore Security Rules (2 minutes)

### 5.1 Go Back to Firebase Console

1. Open: **https://console.firebase.google.com/**
2. Click on your **iTraceLink** project

### 5.2 Update Firestore Rules

1. In left sidebar: **"Build"** → **"Firestore Database"**
2. Click on **"Rules"** tab
3. **Delete** all existing rules
4. **Copy and paste** this entire code:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }

    function getUserType() {
      return getUserData().userType;
    }

    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isOwner(userId);
      allow delete: if false;
    }

    // Seed Producers
    match /seed_producers/{producerId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && getUserType() == 'seed_producer';
      allow update: if isAuthenticated() && getUserType() == 'seed_producer';
      allow delete: if false;
    }

    // Agro Dealers
    match /agro_dealers/{dealerId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && getUserType() == 'agro_dealer';
      allow update: if isAuthenticated() && getUserType() == 'agro_dealer';
      allow delete: if false;
    }

    // Cooperatives
    match /cooperatives/{coopId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && getUserType() == 'farmer';
      allow update: if isAuthenticated() && getUserType() == 'farmer';
      allow delete: if false;
    }

    // Aggregators
    match /aggregators/{aggregatorId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && getUserType() == 'aggregator';
      allow update: if isAuthenticated() && getUserType() == 'aggregator';
      allow delete: if false;
    }

    // Institutions
    match /institutions/{institutionId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && getUserType() == 'institution';
      allow update: if isAuthenticated() && getUserType() == 'institution';
      allow delete: if false;
    }

    // Orders
    match /orders/{orderId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() &&
                     (resource.data.buyerId == request.auth.uid ||
                      resource.data.sellerId == request.auth.uid);
      allow delete: if false;
    }

    // Transactions
    match /transactions/{transactionId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if false;
      allow delete: if false;
    }

    // Notifications
    match /notifications/{notificationId} {
      allow read: if isAuthenticated() && resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() && resource.data.userId == request.auth.uid;
      allow delete: if isAuthenticated() && resource.data.userId == request.auth.uid;
    }
  }
}
```

5. Click **"Publish"**
6. Confirm by clicking **"Publish"** again

### 5.3 Update Storage Rules

1. In left sidebar: **"Build"** → **"Storage"**
2. Click on **"Rules"** tab
3. **Replace** the existing rules with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
                      request.resource.size < 5 * 1024 * 1024; // Max 5MB
    }
  }
}
```

4. Click **"Publish"**

---

## Step 6: Get Your Configuration File (1 minute)

### 6.1 Locate the Generated File

The FlutterFire CLI created a file at:
```
itrace-Link/lib/firebase_options.dart
```

### 6.2 Share This File

**You need to send me this file so I can verify the configuration.**

You have 3 options:

**Option A: Copy File Contents**
1. Open `lib/firebase_options.dart` in any text editor
2. Copy ALL the contents
3. Send to me in chat

**Option B: Commit to Git**
```bash
git add lib/firebase_options.dart
git add android/app/google-services.json
git commit -m "feat: add Firebase configuration"
git push
```

**Option C: Check if It's Already There**
The file might already be in your repository. Check if it exists.

---

## Step 7: Set Up Environment Variables (2 minutes)

### 7.1 Create .env File

1. In your project root, create a file named `.env` (note the dot at the start)
2. Copy this content:

```bash
# Firebase Configuration (already handled by firebase_options.dart)
# No need to add Firebase keys here

# Africa's Talking SMS API (Get these from africastalking.com)
AFRICASTALKING_API_KEY=your_api_key_here
AFRICASTALKING_USERNAME=your_username_here
AFRICASTALKING_SENDER_ID=iTraceLink

# Google Maps API (Get from Google Cloud Console)
GOOGLE_MAPS_API_KEY=your_google_maps_key_here

# Environment
ENVIRONMENT=development
```

3. Save the file

**Note:** For now, you can use placeholder values. We'll set up SMS and Maps later.

---

## Step 8: Test the Setup (2 minutes)

### 8.1 Run the App

In your terminal (make sure you're in the project directory):

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run
```

### 8.2 What to Expect

- App should start without errors
- You should see the splash screen
- Language selection should work
- Login/registration screens should load

### 8.3 If You See Errors

**Error: "No Firebase App '[DEFAULT]' has been created"**
- Solution: Make sure `firebase_options.dart` exists in `lib/` folder
- Run `flutter clean` then `flutter pub get`

**Error: "MissingPluginException"**
- Solution: Stop the app, run `flutter clean`, then `flutter run` again

**Error: "Google Services Plugin"**
- Solution: Make sure `google-services.json` is in `android/app/`

---

## ✅ Checklist: What You Should Have Now

After completing all steps, you should have:

- ✅ Firebase project created
- ✅ Authentication enabled (Email + Phone)
- ✅ Firestore database created
- ✅ Storage enabled
- ✅ Security rules deployed
- ✅ `lib/firebase_options.dart` generated
- ✅ `android/app/google-services.json` generated
- ✅ `.env` file created
- ✅ App runs without errors

---

## 📤 What to Send Me

Please send me:

1. **Confirmation** that all steps completed successfully
2. **Screenshot** of the app running (splash screen is fine)
3. **Any error messages** if something didn't work

I'll then:
- Verify your setup
- Continue building the remaining screens
- Make sure everything is connected properly

---

## 🆘 Troubleshooting

### FlutterFire CLI Not Found

```bash
# Add to PATH (if needed)
# Windows:
setx PATH "%PATH%;%LOCALAPPDATA%\Pub\Cache\bin"

# Mac/Linux:
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

Then try `flutterfire configure` again.

### Firebase Login Fails

```bash
# Logout and login again
firebase logout
firebase login
```

### Can't Find google-services.json

It should be at: `android/app/google-services.json`

If missing:
1. Go to Firebase Console
2. Project Settings (gear icon)
3. Your apps → Android app
4. Download `google-services.json`
5. Place in `android/app/` folder

---

## 🎯 Next Steps (After Setup)

Once Firebase is configured, I will:

1. ✅ Verify your configuration
2. ✅ Create the OTP verification screen
3. ✅ Build all 5 registration forms
4. ✅ Implement all feature screens
5. ✅ Connect everything to Firebase
6. ✅ Test end-to-end flows

---

## 📞 Need Help?

If you get stuck on any step:
1. Take a screenshot of the error
2. Tell me which step you're on
3. I'll help you troubleshoot

---

**Ready to start? Begin with Step 1! 🚀**
