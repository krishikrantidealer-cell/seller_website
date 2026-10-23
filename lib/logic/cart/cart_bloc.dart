import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _cartRepository;

  CartBloc(this._cartRepository) : super(CartInitial()) {
    on<LoadCartEvent>(_onLoadCart);
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateCartQuantityEvent>(_onUpdateQuantity);
    on<RemoveCartItemEvent>(_onRemoveItem);
    on<ClearCartEvent>(_onClearCart);
    on<SyncCartEvent>(_onSyncCart);
  }

  Future<void> _onLoadCart(LoadCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _cartRepository.getCart();
      emit(CartLoadedState(cart));
    } catch (e) {
      emit(CartErrorState(e.toString()));
    }
  }

  Future<void> _onAddToCart(AddToCartEvent event, Emitter<CartState> emit) async {
    try {
      final cart = await _cartRepository.addItem(
        variantId: event.variantId,
        quantity: event.quantity,
      );
      emit(CartLoadedState(cart));
    } catch (e) {
      emit(CartErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateQuantity(UpdateCartQuantityEvent event, Emitter<CartState> emit) async {
    try {
      final cart = await _cartRepository.updateQuantity(
        variantId: event.variantId,
        quantity: event.quantity,
      );
      emit(CartLoadedState(cart));
    } catch (e) {
      emit(CartErrorState(e.toString()));
    }
  }

  Future<void> _onRemoveItem(RemoveCartItemEvent event, Emitter<CartState> emit) async {
    try {
      final cart = await _cartRepository.removeItem(event.variantId);
      emit(CartLoadedState(cart));
    } catch (e) {
      emit(CartErrorState(e.toString()));
    }
  }

  Future<void> _onClearCart(ClearCartEvent event, Emitter<CartState> emit) async {
    try {
      await _cartRepository.clearCart();
      final cart = await _cartRepository.getCart();
      emit(CartLoadedState(cart));
    } catch (e) {
      emit(CartErrorState(e.toString()));
    }
  }

  Future<void> _onSyncCart(SyncCartEvent event, Emitter<CartState> emit) async {
    try {
      final cart = await _cartRepository.syncCart(event.items);
      emit(CartLoadedState(cart));
    } catch (e) {
      emit(CartErrorState(e.toString()));
    }
  }
}
