import 'fastrr_gateway_stub.dart'
    if (dart.library.js) 'fastrr_gateway_web.dart';

class FastrrCheckoutResult {
  final bool success;
  final String? rawResponse;
  final String? errorMessage;

  const FastrrCheckoutResult({
    required this.success,
    this.rawResponse,
    this.errorMessage,
  });
}

abstract class FastrrCheckoutGateway {
  static FastrrCheckoutGateway get instance => createFastrrGateway();

  Future<FastrrCheckoutResult> openCheckout({
    required String storeKey,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    String? customerPhone,
    String? customerName,
  });
}
