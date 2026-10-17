import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/cart_item_model.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final currentItems = List<CartItemModel>.from(state.items);
    final index = currentItems.indexWhere(
      (item) => item.product.id == event.product.id && item.variant.id == event.variant.id,
    );

    if (index >= 0) {
      final existing = currentItems[index];
      currentItems[index] = existing.copyWith(quantity: existing.quantity + event.quantity);
    } else {
      currentItems.add(CartItemModel(
        product: event.product,
        variant: event.variant,
        quantity: event.quantity,
      ));
    }

    emit(state.copyWith(items: currentItems));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final updated = state.items.where(
      (item) => !(item.product.id == event.productId && item.variant.id == event.variantId),
    ).toList();
    emit(state.copyWith(items: updated));
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) {
    if (event.quantity <= 0) {
      add(RemoveFromCart(productId: event.productId, variantId: event.variantId));
      return;
    }

    final currentItems = List<CartItemModel>.from(state.items);
    final index = currentItems.indexWhere(
      (item) => item.product.id == event.productId && item.variant.id == event.variantId,
    );

    if (index >= 0) {
      currentItems[index] = currentItems[index].copyWith(quantity: event.quantity);
      emit(state.copyWith(items: currentItems));
    }
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartState(items: []));
  }
}
