# Setup (one-time steps that cannot be committed)

These files are intentionally not in the repo, so a fresh clone will not build until you do the following.

1. **Generate the missing Android project files** (only `AndroidManifest.xml` and `build.gradle` are committed):
   ```
   flutter create . --platforms=android --org rw.itracelink
   ```
   This fills in what is missing and does not overwrite existing files. Check that the package name matches
   the one in `android/app/src/main/AndroidManifest.xml` and your Firebase app.
2. **Firebase config**
   ```
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This creates `lib/firebase_options.dart` (imported by `main.dart`, git-ignored) and
   `android/app/google-services.json` (git-ignored).
3. **Dependencies and checks**
   ```
   flutter pub get
   flutter analyze
   ```
4. **Deploy security rules** (`firestore.rules` and `storage.rules` in the repo root):
   ```
   firebase deploy --only firestore:rules,storage
   ```
5. **Create an admin** (admins cannot be created from the app): in the Firebase console, set `userType: "admin"`
   on that person's `users/{uid}` document.

## Secrets
Do not put API keys in the app. Anything bundled in the APK can be extracted. SMS (Africa's Talking) should be sent
from a Cloud Function; until then SMS sending is disabled unless keys are supplied some other safe way.
