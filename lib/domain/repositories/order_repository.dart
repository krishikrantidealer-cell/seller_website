import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<OrderEntity> createOrder({
    required String paymentMethod,
    double? advancePercentage,
    required ShippingAddressEntity shippingAddress,
  });
  Future<List<OrderEntity>> getCustomerOrders({int page = 0, int size = 20});
  Future<OrderEntity?> getOrderById(String orderId);
  Future<bool> cancelOrder(String orderId);
}
