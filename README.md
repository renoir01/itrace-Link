# iTraceLink - Iron-Biofortified Beans Traceability System

![iTraceLink Logo](assets/images/logo.png)

**Tracing Nutrition from Seed to Table** | **Gukurikirana Intungamubiri kuva ku mbuto kugeza ku meza**

## Overview

iTraceLink is an Android mobile application designed to create transparency and traceability in the iron-biofortified beans supply chain in Rwanda. The system connects all actors from seed producers to institutional buyers (schools and hospitals), enabling verification of product authenticity and facilitating direct market linkages.

### Target Region
- **Pilot**: Musanze District, Rwanda
- **Scalability**: Expandable to other regions

### Languages Supported
- English
- Kinyarwanda

## Features

### Core Functionalities
1. **User Registration & Profiling** - All actors create and maintain profiles
2. **Supply Chain Linking** - Each transaction creates verifiable links
3. **Product Listing** - Farmers/aggregators list available iron beans
4. **Order Management** - Institutions place orders, notifications sent via SMS
5. **Traceability Queries** - Verify product origin and chain of custody
6. **Bilingual Interface** - Seamless language switching

### User Types
- **Seed Producers** - Research institutions and seed companies
- **Agro-Dealers** - Input suppliers who stock and sell certified seeds
- **Farmers (Cooperatives)** - Bean farmers organized in cooperatives
- **Aggregators** - Traders who collect beans from cooperatives
- **Schools & Hospitals** - Institutional buyers with feeding programs

## Technology Stack

### Mobile Application
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider
- **UI Components**: Material Design 3

### Backend Services
- **Authentication**: Firebase Authentication
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage
- **Cloud Functions**: Firebase Cloud Functions
- **Push Notifications**: Firebase Cloud Messaging (FCM)

### Integrations
- **SMS**: Africa's Talking SMS API
- **Maps**: Google Maps API
- **Analytics**: Firebase Analytics

## Project Structure

```
lib/
├── core/
│   ├── constants/      # App constants and configuration
│   ├── routes/         # App routing configuration
│   ├── theme/          # Theme and styling
│   └── utils/          # Utility functions
├── features/
│   ├── auth/           # Authentication screens and logic
│   ├── dashboard/      # Dashboard screens
│   ├── farmer/         # Farmer-specific features
│   ├── aggregator/     # Aggregator-specific features
│   ├── institution/    # Institution-specific features
│   ├── agro_dealer/    # Agro-dealer features
│   ├── seed_producer/  # Seed producer features
│   ├── orders/         # Order management
│   ├── traceability/   # Traceability features
│   └── notifications/  # Notification management
├── models/             # Data models
├── services/           # Business logic and services
├── widgets/            # Reusable widgets
└── main.dart          # App entry point
```

## Getting Started

### Prerequisites

1. **Flutter SDK** (3.0 or higher)
   ```bash
   flutter --version
   ```

2. **Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

3. **FlutterFire CLI**
   ```bash
   dart pub global activate flutterfire_cli
   ```

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/itrace-Link.git
   cd itrace-Link
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` with your actual API keys and configuration.

4. **Configure Firebase**
   ```bash
   flutterfire configure
   ```
   This will generate `firebase_options.dart` with your Firebase configuration.

5. **Run the app**
   ```bash
   flutter run
   ```

### Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)

2. Enable the following services:
   - Authentication (Phone & Email)
   - Cloud Firestore
   - Cloud Storage
   - Cloud Functions
   - Cloud Messaging
   - Analytics
   - Crashlytics

3. Download configuration files:
   - `google-services.json` for Android (place in `android/app/`)
   - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)

4. Set up Firestore Security Rules (see `firestore.rules`)

### SMS Integration Setup

1. Create an account at [Africa's Talking](https://africastalking.com/)
2. Get your API Key and Username
3. Purchase SMS credits
4. Register sender ID: "iTraceLink"
5. Add credentials to `.env` file

### Google Maps Setup

1. Get a Google Maps API Key from [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the following APIs:
   - Maps SDK for Android
   - Geocoding API
   - Places API
3. Add the API key to `.env` file

## Development Phases

### Phase 1: Foundation (Weeks 1-3) ✅
- [x] Project setup and architecture
- [x] Authentication & user management
- [x] Core UI development

### Phase 2: User-Specific Features (Weeks 4-7)
- [ ] Farmer module
- [ ] Aggregator module
- [ ] Institution module
- [ ] Agro-dealer & seed producer modules

### Phase 3: Integration & Advanced Features (Weeks 8-10)
- [ ] Order management system
- [ ] SMS integration
- [ ] Traceability system

### Phase 4: Testing & Refinement (Weeks 11-12)
- [ ] Unit testing
- [ ] Integration testing
- [ ] User acceptance testing
- [ ] Bug fixes & optimization

### Phase 5: Deployment & Launch (Weeks 13-14)
- [ ] Production deployment
- [ ] Google Play Store listing
- [ ] User training
- [ ] Launch

## Database Schema

The application uses Firebase Firestore with the following collections:

- `users` - Base user authentication data
- `seed_producers` - Seed producer profiles
- `agro_dealers` - Agro-dealer profiles
- `cooperatives` - Farmer cooperative profiles
- `aggregators` - Aggregator profiles
- `institutions` - School/hospital profiles
- `orders` - Order transactions
- `transactions` - Complete transaction history
- `notifications` - User notifications

See the technical specification document for detailed schema.

## Testing

### Run Unit Tests
```bash
flutter test
```

### Run Integration Tests
```bash
flutter test integration_test
```

### Run Widget Tests
```bash
flutter test test/widget_test.dart
```

## Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### iOS Build
```bash
flutter build ios --release
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Code Style

This project follows the official Dart style guide. Run the linter:

```bash
flutter analyze
```

Format your code:

```bash
flutter format .
```

## Security

- All sensitive data is encrypted in transit (HTTPS)
- Passwords are hashed by Firebase Authentication
- Role-based access control implemented
- Firestore security rules enforce data access policies

## Support

For issues, questions, or contributions:
- **Email**: support@itracelink.rw
- **Issues**: [GitHub Issues](https://github.com/yourusername/itrace-Link/issues)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Rwanda Agriculture Board (RAB)
- HarvestPlus Rwanda
- CGIAR
- Local agricultural cooperatives in Musanze District

## Version History

- **1.0.0** (2025-10-30)
  - Initial release
  - Basic authentication and user management
  - User type-specific dashboards
  - Bilingual support (English & Kinyarwanda)

---

**Built with ❤️ for Rwanda's nutrition security**
