import 'package:equatable/equatable.dart';
import '../../domain/entities/order_entity.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class FetchCustomerOrdersEvent extends OrderEvent {
  final int page;
  final int size;

  const FetchCustomerOrdersEvent({this.page = 0, this.size = 20});

  @override
  List<Object?> get props => [page, size];
}

class FetchOrderDetailEvent extends OrderEvent {
  final String orderId;

  const FetchOrderDetailEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class CreateOrderEvent extends OrderEvent {
  final String paymentMethod;
  final double? advancePercentage;
  final ShippingAddressEntity shippingAddress;

  const CreateOrderEvent({
    required this.paymentMethod,
    this.advancePercentage,
    required this.shippingAddress,
  });

  @override
  List<Object?> get props => [paymentMethod, advancePercentage, shippingAddress];
}

class CancelOrderEvent extends OrderEvent {
  final String orderId;

  const CancelOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
