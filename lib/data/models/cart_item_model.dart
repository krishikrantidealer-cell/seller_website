import 'package:equatable/equatable.dart';
import 'product_model.dart';

class CartItemModel extends Equatable {
  final ProductModel product;
  final PackVariant variant;
  final int quantity;

  const CartItemModel({
    required this.product,
    required this.variant,
    this.quantity = 1,
  });

  double get lineTotal => variant.sellingPrice * quantity;
  double get lineSavings => variant.savings * quantity;

  CartItemModel copyWith({
    ProductModel? product,
    PackVariant? variant,
    int? quantity,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      variant: variant ?? this.variant,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product.id, variant.id, quantity];
}
