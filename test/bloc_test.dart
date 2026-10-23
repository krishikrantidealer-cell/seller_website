import 'package:flutter_test/flutter_test.dart';

import 'package:seller_website/domain/entities/user_entity.dart';
import 'package:seller_website/domain/entities/category_entity.dart';
import 'package:seller_website/domain/entities/product_entity.dart';
import 'package:seller_website/domain/entities/cart_entity.dart';
import 'package:seller_website/domain/entities/wishlist_entity.dart';
import 'package:seller_website/domain/entities/order_entity.dart';
import 'package:seller_website/domain/entities/collection_entity.dart';

import 'package:seller_website/domain/repositories/auth_repository.dart';
import 'package:seller_website/domain/repositories/category_repository.dart';
import 'package:seller_website/domain/repositories/product_repository.dart';
import 'package:seller_website/domain/repositories/cart_repository.dart';
import 'package:seller_website/domain/repositories/wishlist_repository.dart';
import 'package:seller_website/domain/repositories/order_repository.dart';

import 'package:seller_website/logic/auth/auth_bloc.dart';
import 'package:seller_website/logic/auth/auth_event.dart';
import 'package:seller_website/logic/auth/auth_state.dart';

import 'package:seller_website/logic/category/category_bloc.dart';
import 'package:seller_website/logic/category/category_event.dart';
import 'package:seller_website/logic/category/category_state.dart';

import 'package:seller_website/logic/product/product_bloc.dart';
import 'package:seller_website/logic/product/product_event.dart';
import 'package:seller_website/logic/product/product_state.dart';

import 'package:seller_website/logic/cart/cart_bloc.dart';
import 'package:seller_website/logic/cart/cart_event.dart';
import 'package:seller_website/logic/cart/cart_state.dart';

import 'package:seller_website/logic/wishlist/wishlist_bloc.dart';
import 'package:seller_website/logic/wishlist/wishlist_event.dart';
import 'package:seller_website/logic/wishlist/wishlist_state.dart';

import 'package:seller_website/logic/order/order_bloc.dart';
import 'package:seller_website/logic/order/order_event.dart';
import 'package:seller_website/logic/order/order_state.dart';

class MockAuthRepository implements AuthRepository {
  bool loggedIn = false;

  @override
  Future<bool> sendOtp(String phoneNumber) async => true;

  @override
  Future<UserEntity> verifyOtp({required String phoneNumber, required String otp}) async {
    loggedIn = true;
    return UserEntity(
      id: 'usr_1',
      phoneNumber: phoneNumber,
      firstName: 'Kisan',
    );
  }

  @override
  Future<UserEntity?> getProfile() async => loggedIn
      ? const UserEntity(id: 'usr_1', phoneNumber: '9876543210', firstName: 'Kisan')
      : null;

  @override
  Future<UserEntity> updateProfile({String? firstName, String? lastName, UserAddressEntity? address}) async {
    return UserEntity(
      id: 'usr_1',
      phoneNumber: '9876543210',
      firstName: firstName ?? 'Kisan',
      lastName: lastName,
      address: address,
    );
  }

  @override
  Future<void> logout() async {
    loggedIn = false;
  }

  @override
  Future<bool> isLoggedIn() async => loggedIn;

  @override
  Future<String?> getCurrentToken() async => loggedIn ? 'mock_jwt_token' : null;
}

class MockCategoryRepository implements CategoryRepository {
  @override
  Future<List<CategoryEntity>> getRootCategories() async => [
        const CategoryEntity(id: 'crop-protection', name: 'Crop Protection', slug: 'crop-protection'),
        const CategoryEntity(id: 'fertilizers', name: 'Fertilizers', slug: 'fertilizers'),
      ];

  @override
  Future<List<CategoryEntity>> getCategoryChildren(String parentId) async => [
        CategoryEntity(id: 'insecticides', name: 'Insecticides', slug: 'insecticides', parentId: parentId),
      ];

  @override
  Future<CategoryEntity?> getCategoryById(String categoryId) async =>
      CategoryEntity(id: categoryId, name: 'Crop Protection', slug: categoryId);
}

class MockProductRepository implements ProductRepository {
  final sampleProduct = const ProductEntity(
    id: 'prod_1',
    sku: 'EBS-P1',
    title: 'Beauveria Bassiana',
    categoryId: 'crop-protection',
    variants: [
      ProductVariantEntity(
        id: 'var_1',
        label: '1 L',
        displayRate: 510.0,
        printedMrp: 1200.0,
      ),
    ],
  );

  @override
  Future<List<ProductEntity>> getProducts({int page = 0, int size = 20}) async => [sampleProduct];

  @override
  Future<ProductEntity?> getProductById(String productId) async => sampleProduct;

  @override
  Future<List<ProductEntity>> getProductsByCategory(String categoryId, {int page = 0, int size = 20}) async =>
      [sampleProduct];

  @override
  Future<List<ProductEntity>> searchProducts(String query, {int page = 0, int size = 20}) async =>
      [sampleProduct];

  @override
  Future<List<CollectionEntity>> getCollections() async => [
        const CollectionEntity(id: 'best-sellers', name: 'Best Sellers', slug: 'best-sellers'),
      ];
}

class MockCartRepository implements CartRepository {
  CartEntity currentCart = const CartEntity();

  @override
  Future<CartEntity> getCart() async => currentCart;

  @override
  Future<int> getCartCount() async => currentCart.totalCount;

  @override
  Future<CartEntity> addItem({required String variantId, int quantity = 1}) async {
    final updated = CartEntity(
      id: 'cart_1',
      items: [
        CartItemEntity(
          id: 'item_1',
          productId: 'prod_1',
          variantId: variantId,
          quantity: quantity,
          price: 510.0,
        ),
      ],
      totalAmount: 1200.0,
      finalAmount: 510.0 * quantity,
    );
    currentCart = updated;
    return updated;
  }

  @override
  Future<CartEntity> updateQuantity({required String variantId, required int quantity}) async {
    return addItem(variantId: variantId, quantity: quantity);
  }

  @override
  Future<CartEntity> removeItem(String variantId) async {
    currentCart = const CartEntity();
    return currentCart;
  }

  @override
  Future<void> clearCart() async {
    currentCart = const CartEntity();
  }

  @override
  Future<CartEntity> syncCart(List<Map<String, dynamic>> items) async => currentCart;
}

class MockWishlistRepository implements WishlistRepository {
  WishlistEntity currentWishlist = const WishlistEntity();

  @override
  Future<WishlistEntity> getWishlist() async => currentWishlist;

  @override
  Future<WishlistEntity> addVariant(String variantId) async {
    currentWishlist = WishlistEntity(variantIds: [variantId]);
    return currentWishlist;
  }

  @override
  Future<WishlistEntity> removeVariant(String variantId) async {
    currentWishlist = const WishlistEntity();
    return currentWishlist;
  }

  @override
  Future<void> clearWishlist() async {
    currentWishlist = const WishlistEntity();
  }
}

class MockOrderRepository implements OrderRepository {
  final sampleOrder = OrderEntity(
    id: 'ORD-1234',
    status: 'Order Confirmed',
    paymentMethod: 'PARTIAL',
    totalAmount: 1200.0,
    shippingAddress: const ShippingAddressEntity(
      name: 'Farmer Test',
      phoneNumber: '9876543210',
      villageArea: 'Karnal',
      cityTehsil: 'Karnal',
      state: 'Haryana',
      pincode: '132001',
    ),
    createdAt: DateTime.now(),
  );

  @override
  Future<OrderEntity> createOrder({
    required String paymentMethod,
    double? advancePercentage,
    required ShippingAddressEntity shippingAddress,
  }) async =>
      sampleOrder;

  @override
  Future<List<OrderEntity>> getCustomerOrders({int page = 0, int size = 20}) async => [sampleOrder];

  @override
  Future<OrderEntity?> getOrderById(String orderId) async => sampleOrder;

  @override
  Future<bool> cancelOrder(String orderId) async => true;
}

void main() {
  group('BLoC State Management & Clean Architecture Tests', () {
    test('AuthBloc transitions through OTP flow properly', () async {
      final repo = MockAuthRepository();
      final bloc = AuthBloc(repo);

      expect(bloc.state, isA<AuthInitial>());

      bloc.add(const SendOtpEvent('9876543210'));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<OtpSentState>().having((s) => s.phoneNumber, 'phone', '9876543210'),
        ]),
      );

      bloc.add(const VerifyOtpEvent(phoneNumber: '9876543210', otp: '123456'));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthenticatedState>().having((s) => s.user.firstName, 'name', 'Kisan'),
        ]),
      );

      bloc.add(LogoutEvent());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<UnauthenticatedState>(),
        ]),
      );

      await bloc.close();
    });

    test('CategoryBloc fetches root categories and updates selection', () async {
      final repo = MockCategoryRepository();
      final bloc = CategoryBloc(repo);

      bloc.add(FetchCategoriesEvent());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CategoryLoading>(),
          isA<CategoriesLoadedState>().having((s) => s.categories.length, 'length', 2),
        ]),
      );

      bloc.add(const SelectCategoryEvent(categoryId: 'crop-protection', subcategory: 'Insecticides'));
      await expectLater(
        bloc.stream,
        emits(
          isA<CategoriesLoadedState>()
              .having((s) => s.selectedCategoryId, 'categoryId', 'crop-protection')
              .having((s) => s.selectedSubcategory, 'subcategory', 'Insecticides'),
        ),
      );

      await bloc.close();
    });

    test('ProductBloc fetches products, detail and handles search', () async {
      final repo = MockProductRepository();
      final bloc = ProductBloc(repo);

      bloc.add(const FetchProductsEvent());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ProductLoading>(),
          isA<ProductsLoadedState>().having((s) => s.products.first.title, 'title', 'Beauveria Bassiana'),
        ]),
      );

      bloc.add(const SearchProductsEvent('Beauveria'));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ProductLoading>(),
          isA<ProductsLoadedState>().having((s) => s.searchQuery, 'query', 'Beauveria'),
        ]),
      );

      await bloc.close();
    });

    test('CartBloc adds, updates and clears items', () async {
      final repo = MockCartRepository();
      final bloc = CartBloc(repo);

      bloc.add(const AddToCartEvent(variantId: 'var_1', quantity: 2));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CartLoadedState>().having((s) => s.cart.totalCount, 'count', 2),
        ]),
      );

      bloc.add(ClearCartEvent());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<CartLoadedState>().having((s) => s.cart.isEmpty, 'isEmpty', true),
        ]),
      );

      await bloc.close();
    });

    test('WishlistBloc toggles and loads items', () async {
      final repo = MockWishlistRepository();
      final bloc = WishlistBloc(repo);

      bloc.add(const ToggleWishlistEvent('var_1'));
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<WishlistLoadedState>().having((s) => s.wishlist.containsVariant('var_1'), 'contains', true),
        ]),
      );

      await bloc.close();
    });

    test('OrderBloc creates orders and fetches order history', () async {
      final repo = MockOrderRepository();
      final bloc = OrderBloc(repo);

      bloc.add(const FetchCustomerOrdersEvent());
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<OrderLoading>(),
          isA<OrdersLoadedState>().having((s) => s.orders.first.id, 'id', 'ORD-1234'),
        ]),
      );

      bloc.add(
        const CreateOrderEvent(
          paymentMethod: 'PARTIAL',
          advancePercentage: 10,
          shippingAddress: ShippingAddressEntity(
            name: 'Kisan',
            phoneNumber: '9876543210',
            villageArea: 'Karnal',
            cityTehsil: 'Karnal',
            state: 'Haryana',
            pincode: '132001',
          ),
        ),
      );
      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<OrderLoading>(),
          isA<OrderCreatedSuccessState>().having((s) => s.order.paymentMethod, 'payment', 'PARTIAL'),
        ]),
      );

      await bloc.close();
    });
  });
}
