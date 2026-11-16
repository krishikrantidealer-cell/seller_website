import 'razorpay_gateway_stub.dart'
    if (dart.library.js) 'razorpay_gateway_web.dart';

/// Payment response callback model
class RazorpaySuccessResult {
  final String paymentId;
  final String orderId;
  final String signature;

  const RazorpaySuccessResult({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  });
}

abstract class RazorpayPaymentGateway {
  static RazorpayPaymentGateway get instance => createPaymentGateway();

  Future<RazorpaySuccessResult?> openCheckout({
    required String keyId,
    required String orderId,
    required int amountPaise,
    required String currency,
    required String name,
    required String description,
    required String prefillContact,
    required String prefillName,
    required String prefillEmail,
  });
}
