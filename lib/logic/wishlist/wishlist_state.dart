import 'package:equatable/equatable.dart';
import '../../domain/entities/wishlist_entity.dart';

abstract class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object?> get props => [];
}

class WishlistInitial extends WishlistState {}

class WishlistLoading extends WishlistState {}

class WishlistLoadedState extends WishlistState {
  final WishlistEntity wishlist;

  const WishlistLoadedState(this.wishlist);

  @override
  List<Object?> get props => [wishlist];
}

class WishlistErrorState extends WishlistState {
  final String message;

  const WishlistErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
