import 'razorpay_payment_gateway.dart';

RazorpayPaymentGateway createPaymentGateway() => StubRazorpayPaymentGateway();

class StubRazorpayPaymentGateway implements RazorpayPaymentGateway {
  @override
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
  }) async {
    // Stub implementation for test / headless environments
    return RazorpaySuccessResult(
      paymentId: 'pay_sim_${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      signature: 'simulated_signature_ok',
    );
  }
}
