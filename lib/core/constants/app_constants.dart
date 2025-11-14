class AppConstants {
  // App Info
  static const String appName = 'iTraceLink';
  static const String appVersion = '1.0.0';
  static const String appTaglineEn = 'Tracing Nutrition from Seed to Table';
  static const String appTaglineRw = 'Gukurikirana Intungamubiri kuva ku mbuto kugeza ku meza';

  // User Types
  static const String userTypeSeedProducer = 'seed_producer';
  static const String userTypeAgroDealer = 'agro_dealer';
  static const String userTypeFarmer = 'farmer';
  static const String userTypeAggregator = 'aggregator';
  static const String userTypeInstitution = 'institution';

  // Order Status
  static const String orderStatusPending = 'pending';
  static const String orderStatusAccepted = 'accepted';
  static const String orderStatusRejected = 'rejected';
  static const String orderStatusCompleted = 'completed';
  static const String orderStatusCancelled = 'cancelled';

  // Payment Status
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusPaid = 'paid';

  // Transaction Types
  static const String transactionTypeSeedSale = 'seed_sale';
  static const String transactionTypeBeanSale = 'bean_sale';
  static const String transactionTypeBeanCollection = 'bean_collection';
  static const String transactionTypeBeanDelivery = 'bean_delivery';

  // Order Types
  static const String orderTypeAggregatorToFarmer = 'aggregator_to_farmer';
  static const String orderTypeInstitutionToAggregator = 'institution_to_aggregator';

  // Institution Types
  static const String institutionTypeSchool = 'school';
  static const String institutionTypeHospital = 'hospital';

  // Notification Types
  static const String notificationTypeOrder = 'order';
  static const String notificationTypePayment = 'payment';
  static const String notificationTypeAlert = 'alert';

  // Languages
  static const String languageEnglish = 'en';
  static const String languageKinyarwanda = 'rw';

  // Firebase Collections
  static const String collectionUsers = 'users';
  static const String collectionSeedProducers = 'seed_producers';
  static const String collectionAgroDealers = 'agro_dealers';
  static const String collectionCooperatives = 'cooperatives';
  static const String collectionAggregators = 'aggregators';
  static const String collectionInstitutions = 'institutions';
  static const String collectionOrders = 'orders';
  static const String collectionTransactions = 'transactions';
  static const String collectionNotifications = 'notifications';

  // Rwanda Districts (Pilot: Musanze)
  static const List<String> rwandaDistricts = [
    'Musanze',
    'Gasabo',
    'Kicukiro',
    'Nyarugenge',
    'Bugesera',
    'Gatsibo',
    'Kayonza',
    'Kirehe',
    'Ngoma',
    'Nyagatare',
    'Rwamagana',
    'Huye',
    'Gisagara',
    'Kamonyi',
    'Muhanga',
    'Nyamagabe',
    'Nyanza',
    'Nyaruguru',
    'Ruhango',
    'Karongi',
    'Ngororero',
    'Nyabihu',
    'Nyamasheke',
    'Rubavu',
    'Rusizi',
    'Rutsiro',
    'Gicumbi',
    'Rulindo',
    'Gakenke',
    'Burera',
  ];

  // Bean Quality Grades
  static const List<String> beanQualityGrades = ['A', 'B', 'C'];

  // Seed Varieties
  static const List<String> ironBeanVarieties = [
    'RWR 2245',
    'RWR 2154',
    'MAC 44',
    'CAL 143',
  ];

  // Validation
  static const int minPasswordLength = 8;
  static const int otpLength = 6;
  static const int otpValidityMinutes = 10;

  // SMS Templates
  static const String smsOrderNotificationEn =
      'New order from {aggregatorName}: {quantity}kg @ {price} RWF/kg. Delivery: {date}. Open iTraceLink to respond.';

  static const String smsOrderNotificationRw =
      'Itungo rishya rya {aggregatorName}: {quantity}kg @ {price} RWF/kg. Itariki: {date}. Fungura iTraceLink ugire icyo ubwira.';

  static const String smsOrderAcceptedEn =
      '{coopName} accepted your order for {quantity}kg. Collection: {date} at {location}.';

  static const String smsOrderAcceptedRw =
      '{coopName} yemeye itungo ryawe rya {quantity}kg. Kugarurira: {date} kuri {location}.';

  static const String smsOtpEn =
      'Your iTraceLink verification code is: {code}. Valid for 10 minutes.';

  static const String smsOtpRw =
      'Kode yawe ya iTraceLink ni: {code}. Ikoreshwa mu minota 10.';

  // API Endpoints
  static const String apiBaseUrl = 'https://api.africastalking.com/version1';
  static const String apiSmsEndpoint = '/messaging';

  // Storage Paths
  static const String storageProfileImages = 'profile_images';
  static const String storageDocuments = 'documents';
  static const String storagePlantingPhotos = 'planting_photos';
  static const String storageHarvestPhotos = 'harvest_photos';
  static const String storageDeliveryPhotos = 'delivery_photos';

  // Shared Preferences Keys
  static const String keyLanguage = 'language';
  static const String keyUserId = 'user_id';
  static const String keyUserType = 'user_type';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyOnboardingComplete = 'onboarding_complete';
}
