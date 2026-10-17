import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddToCart extends CartEvent {
  final ProductModel product;
  final PackVariant variant;
  final int quantity;

  const AddToCart({
    required this.product,
    required this.variant,
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [product.id, variant.id, quantity];
}

class RemoveFromCart extends CartEvent {
  final String productId;
  final String variantId;

  const RemoveFromCart({required this.productId, required this.variantId});

  @override
  List<Object?> get props => [productId, variantId];
}

class UpdateQuantity extends CartEvent {
  final String productId;
  final String variantId;
  final int quantity;

  const UpdateQuantity({
    required this.productId,
    required this.variantId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, variantId, quantity];
}

class ClearCart extends CartEvent {
  const ClearCart();
}
