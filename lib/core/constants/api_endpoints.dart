class ApiEndpoints {
  /// Base URL for the backend API, configurable via `--dart-define=API_BASE_URL=https://...`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  /// Authentication (OTP & Password)
  static const String sendOtp = '/api/v1/auth/otp/send';
  static const String verifyOtp = '/api/v1/auth/otp/verify';
  static const String refreshToken = '/api/v1/auth/refresh';
  static const String logout = '/api/v1/auth/logout';

  /// Categories (Public 3-tier hierarchy: Level 0, Level 1, Level 2)
  static const String categories = '/api/v1/categories';
  static String categoryById(String id) => '/api/v1/categories/$id';

  /// Products & Collections (Public storefront catalog)
  static const String products = '/api/v1/products';
  static String productById(String id) => '/api/v1/products/$id';
  static const String collections = '/api/v1/collections';
  static String collectionById(String id) => '/api/v1/collections/$id';

  /// Customer Cart, Wishlist & Orders
  static const String cart = '/api/v1/cart';
  static const String wishlist = '/api/v1/wishlist';
  static const String orders = '/api/v1/orders';
}
