import 'package:equatable/equatable.dart';
import 'product_entity.dart';

class CartItemEntity extends Equatable {
  final String id;
  final String productId;
  final String variantId;
  final int quantity;
  final double price;
  final ProductEntity? product;
  final ProductVariantEntity? variant;

  const CartItemEntity({
    required this.id,
    required this.productId,
    required this.variantId,
    required this.quantity,
    required this.price,
    this.product,
    this.variant,
  });

  double get totalRate => price * quantity;
  double get totalMrp => (variant?.printedMrp ?? price) * quantity;
  double get totalSavings => totalMrp - totalRate;

  CartItemEntity copyWith({
    String? id,
    String? productId,
    String? variantId,
    int? quantity,
    double? price,
    ProductEntity? product,
    ProductVariantEntity? variant,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      variantId: variantId ?? this.variantId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      product: product ?? this.product,
      variant: variant ?? this.variant,
    );
  }

  @override
  List<Object?> get props => [id, productId, variantId, quantity, price, product, variant];
}

class CartEntity extends Equatable {
  final String? id;
  final List<CartItemEntity> items;
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;

  const CartEntity({
    this.id,
    this.items = const [],
    this.totalAmount = 0.0,
    this.discountAmount = 0.0,
    this.finalAmount = 0.0,
  });

  int get totalCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;

  static const double freeShippingThreshold = 500.0;
  bool get hasFreeShipping => finalAmount >= freeShippingThreshold;
  double get amountNeededForFreeShipping =>
      (freeShippingThreshold - finalAmount).clamp(0.0, freeShippingThreshold);
  double get freeShippingProgress =>
      (finalAmount / freeShippingThreshold).clamp(0.0, 1.0);

  @override
  List<Object?> get props => [id, items, totalAmount, discountAmount, finalAmount];
}
