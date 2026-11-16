import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage {
  final String code;
  final String shortCode;
  final String name;
  final String nativeName;

  const AppLanguage({
    required this.code,
    required this.shortCode,
    required this.name,
    required this.nativeName,
  });
}

class LanguageController extends ChangeNotifier {
  LanguageController._();
  static final LanguageController instance = LanguageController._();

  static const String _prefKey = 'ebs_selected_language_code';

  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(code: 'en', shortCode: 'EN', name: 'English', nativeName: 'English'),
    AppLanguage(code: 'hi', shortCode: 'HI', name: 'Hindi', nativeName: 'हिन्दी'),
    AppLanguage(code: 'mr', shortCode: 'MR', name: 'Marathi', nativeName: 'मराठी'),
    AppLanguage(code: 'pa', shortCode: 'PA', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ'),
    AppLanguage(code: 'gu', shortCode: 'GU', name: 'Gujarati', nativeName: 'ગુજરાતી'),
    AppLanguage(code: 'te', shortCode: 'TE', name: 'Telugu', nativeName: 'తెలుగు'),
    AppLanguage(code: 'ta', shortCode: 'TA', name: 'Tamil', nativeName: 'தமிழ்'),
  ];

  AppLanguage _current = supportedLanguages.first;
  AppLanguage get current => _current;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefKey);
      if (savedCode != null) {
        final match = supportedLanguages.where((l) => l.code == savedCode);
        if (match.isNotEmpty) {
          _current = match.first;
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_current.code == language.code) return;
    _current = language;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, language.code);
    } catch (_) {}
  }

  String tr(String key) {
    final code = _current.code;
    return _translations[code]?[key] ?? _translations['en']![key] ?? key;
  }

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'call_to_order': 'Call to Order',
      'helpline': 'Helpline',
      'free_delivery': 'Free Pan-India Delivery',
      'be_a_partner': 'Be a Partner',
      'sell_with_us': 'Sell with Us',
      'choose_language': 'Choose Language',
    },
    'hi': {
      'call_to_order': 'ऑर्डर के लिए कॉल करें',
      'helpline': 'हेल्पलाइन',
      'free_delivery': 'पूरे भारत में मुफ़्त डिलीवरी',
      'be_a_partner': 'पार्टनर बनें',
      'sell_with_us': 'हमारे साथ बेचें',
      'choose_language': 'भाषा चुनें',
    },
    'mr': {
      'call_to_order': 'ऑर्डरसाठी कॉल करा',
      'helpline': 'हेल्पलाइन',
      'free_delivery': 'संपूर्ण भारतात मोफत डिलिव्हरी',
      'be_a_partner': 'भागीदार व्हा',
      'sell_with_us': 'आमच्यासोबत विका',
      'choose_language': 'भाषा निवडा',
    },
    'pa': {
      'call_to_order': 'ਆਰਡਰ ਲਈ ਕਾਲ ਕਰੋ',
      'helpline': 'ਹੈਲਪਲਾਈਨ',
      'free_delivery': 'ਪੂਰੇ ਭਾਰਤ ਵਿੱਚ ਮੁਫ਼ਤ ਡਿਲੀਵਰੀ',
      'be_a_partner': 'ਪਾਰਟਨਰ ਬਣੋ',
      'sell_with_us': 'ਸਾਡੇ ਨਾਲ ਵੇਚੋ',
      'choose_language': 'ਭਾਸ਼ਾ ਚੁਣੋ',
    },
    'gu': {
      'call_to_order': 'ઓર્ડર માટે કૉલ કરો',
      'helpline': 'હેલ્પલાઇન',
      'free_delivery': 'સમગ્ર ભારતમાં મફત ડિલિવરી',
      'be_a_partner': 'પાર્ટનર બનો',
      'sell_with_us': 'અમારી સાથે વેચો',
      'choose_language': 'ભાષા પસંદ કરો',
    },
    'te': {
      'call_to_order': 'ఆర్డర్ కోసం కాల్ చేయండి',
      'helpline': 'హెల్ప్‌లైన్',
      'free_delivery': 'భారతదేశమంతా ఉచిత డెలివరీ',
      'be_a_partner': 'భాగస్వామి అవ్వండి',
      'sell_with_us': 'మాతో అమ్మండి',
      'choose_language': 'భాషను ఎంచుకోండి',
    },
    'ta': {
      'call_to_order': 'ஆர்டருக்கு அழைக்கவும்',
      'helpline': 'உதவி எண்',
      'free_delivery': 'இந்தியா முழுவதும் இலவச டெலிவரி',
      'be_a_partner': 'கூட்டாளர் ஆகுங்கள்',
      'sell_with_us': 'எங்களுடன் விற்கவும்',
      'choose_language': 'மொழியைத் தேர்ந்தெடுக்கவும்',
    },
  };
}
