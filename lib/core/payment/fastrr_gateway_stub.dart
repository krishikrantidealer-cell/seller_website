import 'fastrr_checkout_gateway.dart';

FastrrCheckoutGateway createFastrrGateway() => StubFastrrCheckoutGateway();

class StubFastrrCheckoutGateway implements FastrrCheckoutGateway {
  @override
  Future<FastrrCheckoutResult> openCheckout({
    required String storeKey,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    String? customerPhone,
    String? customerName,
  }) async {
    return const FastrrCheckoutResult(
      success: true,
      rawResponse: '{"mock": "fastrr_stub_ok"}',
    );
  }
}
