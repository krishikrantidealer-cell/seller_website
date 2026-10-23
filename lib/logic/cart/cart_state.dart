import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_entity.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoadedState extends CartState {
  final CartEntity cart;

  const CartLoadedState(this.cart);

  @override
  List<Object?> get props => [cart];
}

class CartErrorState extends CartState {
  final String message;

  const CartErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
