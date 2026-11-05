import 'api_endpoints.dart';

class AppConstants {
  static const String appName = 'EBS Essential BioCrop Science';
  static const String appTagline = 'Pioneering Agricultural Excellence & Crop Nutrition';
  static const String helplineNumber = '+91 9098544263';
  static const String orderCallNumber = '+91 9098544263';
  static const String sellerPortalUrl = 'https://abadmin.agribegri.com/sellerpanel/login.php';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.agribegri';

  // Social Media Links
  static const String facebookUrl = 'https://www.facebook.com/people/Essential-Bio-Crop-Science/61592423459339/';
  static const String instagramUrl = 'https://www.instagram.com/essentialbiocropscience/';
  static const String youtubeUrl = 'https://www.youtube.com/channel/UC9-t4UP6f4JIb7MWuUXbzEA';

  // Backend base URL (points to local development backend on port 8080, overridable via --dart-define=API_BASE_URL=...)
  static String get apiBaseUrl {
    const base = ApiEndpoints.baseUrl;
    return base.endsWith('/api/v1') ? base : '$base/api/v1';
  }
}
