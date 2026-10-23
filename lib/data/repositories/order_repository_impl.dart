import '../../core/storage/token_storage.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';
import '../models/api/order_dto.dart';
import '../models/order_models.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  OrderRepositoryImpl(this._remoteDataSource, this._tokenStorage);

  OrderEntity _mapSampleToEntity(OrderModel o) {
    return OrderEntity(
      id: o.id,
      status: o.status.displayName,
      paymentMethod: o.paymentMethod,
      totalAmount: o.totalAmount,
      shippingAddress: ShippingAddressEntity(
        name: o.recipientName,
        phoneNumber: o.recipientPhone,
        villageArea: o.deliveryAddress,
        cityTehsil: '',
        state: '',
        pincode: '',
      ),
      items: o.items
          .map(
            (i) => OrderItemEntity(
              productId: i.product.id,
              variantId: i.variant.id,
              productTitle: i.product.title,
              variantLabel: i.variant.label,
              imageUrl: i.product.imageUrl,
              quantity: i.quantity,
              unitPrice: i.unitPrice,
              totalPrice: i.totalPrice,
            ),
          )
          .toList(),
      createdAt: o.orderDate,
      trackingId: o.awbNumber,
      courierPartner: o.courierName,
    );
  }

  @override
  Future<OrderEntity> createOrder({
    required String paymentMethod,
    double? advancePercentage,
    required ShippingAddressEntity shippingAddress,
  }) async {
    final payload = {
      'paymentMethod': paymentMethod,
      'advancePercentage': ?advancePercentage,
      'shippingAddress': shippingAddress.toJson(),
    };

    final hasToken = await _tokenStorage.hasAccessToken();
    if (hasToken) {
      try {
        final data = await _remoteDataSource.createOrder(payload);
        if (data.isNotEmpty) {
          return OrderDto.fromJson(data).toEntity();
        }
      } catch (_) {}
    }

    // Local fallback order creation
    final id = 'ORD-EBS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    return OrderEntity(
      id: id,
      status: 'Order Confirmed',
      paymentMethod: paymentMethod,
      advancePercentage: advancePercentage,
      totalAmount: 1200.0,
      advancePaid: paymentMethod == 'PARTIAL' ? 120.0 : 1200.0,
      balanceDue: paymentMethod == 'PARTIAL' ? 1080.0 : 0.0,
      shippingAddress: shippingAddress,
      createdAt: DateTime.now(),
      trackingId: 'TRK-${id.substring(4)}',
      courierPartner: 'Delhivery Express',
    );
  }

  @override
  Future<List<OrderEntity>> getCustomerOrders({int page = 0, int size = 20}) async {
    final hasToken = await _tokenStorage.hasAccessToken();
    if (hasToken) {
      try {
        final list = await _remoteDataSource.getCustomerOrders(page: page, size: size);
        if (list.isNotEmpty) {
          return list
              .whereType<Map<String, dynamic>>()
              .map((json) => OrderDto.fromJson(json).toEntity())
              .toList();
        }
      } catch (_) {}
    }

    return OrderModel.sampleOrders.map(_mapSampleToEntity).toList();
  }

  @override
  Future<OrderEntity?> getOrderById(String orderId) async {
    final hasToken = await _tokenStorage.hasAccessToken();
    if (hasToken) {
      try {
        final data = await _remoteDataSource.getOrderById(orderId);
        if (data.isNotEmpty) {
          return OrderDto.fromJson(data).toEntity();
        }
      } catch (_) {}
    }

    final sample = OrderModel.sampleOrders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => OrderModel.sampleOrders.first,
    );
    return _mapSampleToEntity(sample);
  }

  @override
  Future<bool> cancelOrder(String orderId) async {
    final hasToken = await _tokenStorage.hasAccessToken();
    if (hasToken) {
      try {
        return await _remoteDataSource.cancelOrder(orderId);
      } catch (_) {}
    }
    return true;
  }
}
