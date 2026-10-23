import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';

abstract class OrderRemoteDataSource {
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> payload);
  Future<List<dynamic>> getCustomerOrders({int page = 0, int size = 20});
  Future<Map<String, dynamic>> getOrderById(String orderId);
  Future<bool> cancelOrder(String orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient _client;

  OrderRemoteDataSourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> payload) async {
    final response = await _client.post(
      ApiEndpoints.createOrder,
      body: payload,
      requiresAuth: true,
    );
    if (response is Map && response['data'] is Map) {
      return response['data'] as Map<String, dynamic>;
    }
    return response is Map<String, dynamic> ? response : {};
  }

  @override
  Future<List<dynamic>> getCustomerOrders({int page = 0, int size = 20}) async {
    final response = await _client.get(
      ApiEndpoints.customerOrders(page: page, size: size),
      requiresAuth: true,
    );
    if (response is Map && response['data'] is Map && response['data']['content'] is List) {
      return response['data']['content'] as List<dynamic>;
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    final response = await _client.get(
      ApiEndpoints.orderById(orderId),
      requiresAuth: true,
    );
    if (response is Map && response['data'] is Map) {
      return response['data'] as Map<String, dynamic>;
    }
    return {};
  }

  @override
  Future<bool> cancelOrder(String orderId) async {
    final response = await _client.post(
      ApiEndpoints.cancelOrder(orderId),
      requiresAuth: true,
    );
    return response is Map && response['success'] == true;
  }
}
