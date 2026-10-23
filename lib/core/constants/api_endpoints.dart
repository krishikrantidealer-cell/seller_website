class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'https://ebs-biocrop-backend.onrender.com';
  static const String apiV1 = '$baseUrl/api/v1';

  // Health
  static const String health = '$apiV1/health';

  // Auth (Customer)
  static const String sendOtp = '$apiV1/auth/otp/send';
  static const String verifyOtp = '$apiV1/auth/otp/verify';
  static const String refreshToken = '$apiV1/auth/token/refresh';

  // User Profile
  static const String userProfile = '$apiV1/user/profile';

  // Products
  static const String products = '$apiV1/products';
  static String productDetail(String productId) => '$apiV1/products/$productId';
  static String productsByCategory(String categoryId, {int page = 0, int size = 20}) =>
      '$apiV1/products/category/$categoryId?page=$page&size=$size';
  static String searchProducts(String query, {int page = 0, int size = 20}) =>
      '$apiV1/products/search?q=${Uri.encodeComponent(query)}&page=$page&size=$size';

  // Categories
  static const String categories = '$apiV1/categories';
  static String categoryRoots({int level = 0}) => '$apiV1/categories?level=$level';
  static String categoryChildren(String parentId) => '$apiV1/categories?parentId=$parentId';
  static String categoryById(String categoryId) => '$apiV1/categories/$categoryId';

  // Collections
  static const String collections = '$apiV1/collections';
  static String collectionBySlug(String slug) => '$apiV1/collections/$slug';

  // Cart (ROLE_CUSTOMER)
  static const String cart = '$apiV1/cart';
  static const String cartCount = '$apiV1/cart/count';
  static const String cartSync = '$apiV1/cart/sync';
  static const String cartItems = '$apiV1/cart/items';
  static String cartItem(String variantId) => '$apiV1/cart/items/$variantId';

  // Wishlist (ROLE_CUSTOMER)
  static const String wishlist = '$apiV1/wishlist';
  static String wishlistItem(String variantId) => '$apiV1/wishlist/items/$variantId';

  // Orders
  static const String createOrder = '$apiV1/orders/create';
  static String customerOrders({int page = 0, int size = 20}) =>
      '$apiV1/orders/customer?page=$page&size=$size';
  static String orderById(String orderId) => '$apiV1/orders/$orderId';
  static String orderGroupByCheckoutId(String checkoutGroupId) =>
      '$apiV1/orders/group/$checkoutGroupId';
  static String cancelOrder(String orderId) => '$apiV1/orders/$orderId/cancel';

  // Blogs (Public)
  static const String blogs = '$apiV1/blogs';
  static String blogBySlug(String slug) => '$apiV1/blogs/$slug';
  static const String blogCategories = '$apiV1/blogs/categories';
  static const String blogTags = '$apiV1/blogs/tags';
}
