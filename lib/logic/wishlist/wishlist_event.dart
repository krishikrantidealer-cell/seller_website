import 'package:equatable/equatable.dart';

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();

  @override
  List<Object?> get props => [];
}

class LoadWishlistEvent extends WishlistEvent {}

class ToggleWishlistEvent extends WishlistEvent {
  final String variantId;

  const ToggleWishlistEvent(this.variantId);

  @override
  List<Object?> get props => [variantId];
}

class RemoveWishlistItemEvent extends WishlistEvent {
  final String variantId;

  const RemoveWishlistItemEvent(this.variantId);

  @override
  List<Object?> get props => [variantId];
}

class ClearWishlistEvent extends WishlistEvent {}
