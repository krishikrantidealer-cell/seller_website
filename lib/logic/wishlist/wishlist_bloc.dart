import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/wishlist_repository.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final WishlistRepository _wishlistRepository;

  WishlistBloc(this._wishlistRepository) : super(WishlistInitial()) {
    on<LoadWishlistEvent>(_onLoadWishlist);
    on<ToggleWishlistEvent>(_onToggleWishlist);
    on<RemoveWishlistItemEvent>(_onRemoveItem);
    on<ClearWishlistEvent>(_onClearWishlist);
  }

  Future<void> _onLoadWishlist(LoadWishlistEvent event, Emitter<WishlistState> emit) async {
    emit(WishlistLoading());
    try {
      final wishlist = await _wishlistRepository.getWishlist();
      emit(WishlistLoadedState(wishlist));
    } catch (e) {
      emit(WishlistErrorState(e.toString()));
    }
  }

  Future<void> _onToggleWishlist(ToggleWishlistEvent event, Emitter<WishlistState> emit) async {
    try {
      final currentWishlist = state is WishlistLoadedState
          ? (state as WishlistLoadedState).wishlist
          : await _wishlistRepository.getWishlist();

      if (currentWishlist.containsVariant(event.variantId)) {
        final updated = await _wishlistRepository.removeVariant(event.variantId);
        emit(WishlistLoadedState(updated));
      } else {
        final updated = await _wishlistRepository.addVariant(event.variantId);
        emit(WishlistLoadedState(updated));
      }
    } catch (e) {
      emit(WishlistErrorState(e.toString()));
    }
  }

  Future<void> _onRemoveItem(RemoveWishlistItemEvent event, Emitter<WishlistState> emit) async {
    try {
      final updated = await _wishlistRepository.removeVariant(event.variantId);
      emit(WishlistLoadedState(updated));
    } catch (e) {
      emit(WishlistErrorState(e.toString()));
    }
  }

  Future<void> _onClearWishlist(ClearWishlistEvent event, Emitter<WishlistState> emit) async {
    try {
      await _wishlistRepository.clearWishlist();
      final updated = await _wishlistRepository.getWishlist();
      emit(WishlistLoadedState(updated));
    } catch (e) {
      emit(WishlistErrorState(e.toString()));
    }
  }
}
