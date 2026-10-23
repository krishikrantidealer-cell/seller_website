import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;

  OrderBloc(this._orderRepository) : super(OrderInitial()) {
    on<FetchCustomerOrdersEvent>(_onFetchOrders);
    on<FetchOrderDetailEvent>(_onFetchOrderDetail);
    on<CreateOrderEvent>(_onCreateOrder);
    on<CancelOrderEvent>(_onCancelOrder);
  }

  Future<void> _onFetchOrders(FetchCustomerOrdersEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final orders = await _orderRepository.getCustomerOrders(page: event.page, size: event.size);
      emit(OrdersLoadedState(orders));
    } catch (e) {
      emit(OrderErrorState(e.toString()));
    }
  }

  Future<void> _onFetchOrderDetail(FetchOrderDetailEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final order = await _orderRepository.getOrderById(event.orderId);
      if (order != null) {
        emit(OrderDetailLoadedState(order));
      } else {
        emit(const OrderErrorState('Order not found'));
      }
    } catch (e) {
      emit(OrderErrorState(e.toString()));
    }
  }

  Future<void> _onCreateOrder(CreateOrderEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final order = await _orderRepository.createOrder(
        paymentMethod: event.paymentMethod,
        advancePercentage: event.advancePercentage,
        shippingAddress: event.shippingAddress,
      );
      emit(OrderCreatedSuccessState(order));
    } catch (e) {
      emit(OrderErrorState(e.toString()));
    }
  }

  Future<void> _onCancelOrder(CancelOrderEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final success = await _orderRepository.cancelOrder(event.orderId);
      if (success) {
        final orders = await _orderRepository.getCustomerOrders();
        emit(OrdersLoadedState(orders));
      } else {
        emit(const OrderErrorState('Failed to cancel order'));
      }
    } catch (e) {
      emit(OrderErrorState(e.toString()));
    }
  }
}
