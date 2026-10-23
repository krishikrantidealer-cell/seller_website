import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCartEvent extends CartEvent {}

class AddToCartEvent extends CartEvent {
  final String variantId;
  final int quantity;

  const AddToCartEvent({required this.variantId, this.quantity = 1});

  @override
  List<Object?> get props => [variantId, quantity];
}

class UpdateCartQuantityEvent extends CartEvent {
  final String variantId;
  final int quantity;

  const UpdateCartQuantityEvent({required this.variantId, required this.quantity});

  @override
  List<Object?> get props => [variantId, quantity];
}

class RemoveCartItemEvent extends CartEvent {
  final String variantId;

  const RemoveCartItemEvent(this.variantId);

  @override
  List<Object?> get props => [variantId];
}

class ClearCartEvent extends CartEvent {}

class SyncCartEvent extends CartEvent {
  final List<Map<String, dynamic>> items;

  const SyncCartEvent(this.items);

  @override
  List<Object?> get props => [items];
}
