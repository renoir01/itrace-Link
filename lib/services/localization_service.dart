import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();
  static LocalizationService get instance => _instance;

  LocalizationService._internal();

  Locale _currentLocale = const Locale('en', 'US');
  Locale get currentLocale => _currentLocale;

  bool get isEnglish => _currentLocale.languageCode == 'en';
  bool get isKinyarwanda => _currentLocale.languageCode == 'rw';

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(AppConstants.keyLanguage) ?? 'en';
    _currentLocale = Locale(languageCode, languageCode == 'en' ? 'US' : 'RW');
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLanguage, languageCode);
    _currentLocale = Locale(languageCode, languageCode == 'en' ? 'US' : 'RW');
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    final newLanguageCode = isEnglish ? 'rw' : 'en';
    await setLanguage(newLanguageCode);
  }

  // Translation helper - would be replaced by actual translation files
  String translate(String key) {
    // This is a placeholder. In production, use proper localization files
    final translations = _getTranslations();
    return translations[_currentLocale.languageCode]?[key] ?? key;
  }

  Map<String, Map<String, String>> _getTranslations() {
    return {
      'en': {
        'app_name': 'iTraceLink',
        'welcome': 'Welcome',
        'login': 'Login',
        'register': 'Register',
        'phone_number': 'Phone Number',
        'email': 'Email',
        'password': 'Password',
        'forgot_password': 'Forgot Password?',
        'select_user_type': 'Who are you?',
        'seed_producer': 'Seed Producer',
        'agro_dealer': 'Agro-Dealer',
        'farmer_coop': 'Farmer Cooperative',
        'aggregator': 'Aggregator',
        'institution': 'School/Hospital',
        'dashboard': 'Dashboard',
        'profile': 'Profile',
        'notifications': 'Notifications',
        'orders': 'Orders',
        'place_order': 'Place Order',
        'accept_order': 'Accept Order',
        'reject_order': 'Reject Order',
        'quantity_kg': 'Quantity (kg)',
        'price_rwf': 'Price (RWF/kg)',
        'delivery_date': 'Delivery Date',
        'submit': 'Submit',
        'cancel': 'Cancel',
        'save': 'Save',
        'next': 'Next',
        'previous': 'Previous',
        'logout': 'Logout',
        'settings': 'Settings',
        'language': 'Language',
        'english': 'English',
        'kinyarwanda': 'Kinyarwanda',
      },
      'rw': {
        'app_name': 'iTraceLink',
        'welcome': 'Murakaza neza',
        'login': 'Injira',
        'register': 'Iyandikishe',
        'phone_number': 'Nimero ya Telefoni',
        'email': 'Imeyili',
        'password': 'Ijambo Ryibanga',
        'forgot_password': 'Wibagiwe Ijambo Ryibanga?',
        'select_user_type': 'Wowe uri iki?',
        'seed_producer': 'Umushoramari w\'Imbuto',
        'agro_dealer': 'Ucuruza Imbuto',
        'farmer_coop': 'Koperative y\'Abahinzi',
        'aggregator': 'Uwegeranya',
        'institution': 'Ishuri/Ibitaro',
        'dashboard': 'Ibanze',
        'profile': 'Umwirondoro',
        'notifications': 'Ubutumwa',
        'orders': 'Amatungo',
        'place_order': 'Saba Ibicuruzwa',
        'accept_order': 'Emera Itungo',
        'reject_order': 'Anga Itungo',
        'quantity_kg': 'Ingano (kg)',
        'price_rwf': 'Igiciro (RWF/kg)',
        'delivery_date': 'Itariki yo Gutanga',
        'submit': 'Ohereza',
        'cancel': 'Hagarika',
        'save': 'Bika',
        'next': 'Ibikurikira',
        'previous': 'Ibanjirije',
        'logout': 'Sohoka',
        'settings': 'Igenamiterere',
        'language': 'Ururimi',
        'english': 'Icyongereza',
        'kinyarwanda': 'Ikinyarwanda',
      },
    };
  }
}
