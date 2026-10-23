import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrdersLoadedState extends OrderState {
  final List<OrderEntity> orders;

  const OrdersLoadedState(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderDetailLoadedState extends OrderState {
  final OrderEntity order;

  const OrderDetailLoadedState(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderCreatedSuccessState extends OrderState {
  final OrderEntity order;

  const OrderCreatedSuccessState(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderErrorState extends OrderState {
  final String message;

  const OrderErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
