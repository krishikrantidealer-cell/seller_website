// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'razorpay_payment_gateway.dart';

RazorpayPaymentGateway createPaymentGateway() => WebRazorpayPaymentGateway();

class WebRazorpayPaymentGateway implements RazorpayPaymentGateway {
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
    final completer = Completer<RazorpaySuccessResult?>();

    final options = {
      'key': keyId,
      'amount': amountPaise,
      'currency': currency,
      'name': name,
      'description': description,
      'order_id': orderId,
      'prefill': {
        'name': prefillName,
        'contact': prefillContact,
        'email': prefillEmail,
      },
      'theme': {
        'color': '#16A34A', // Brand green
      },
    };

    try {
      final hasLauncher = globalContext.has('launchRazorpayCheckout');
      if (!hasLauncher) {
        return RazorpaySuccessResult(
          paymentId: 'pay_sim_${DateTime.now().millisecondsSinceEpoch}',
          orderId: orderId,
          signature: 'simulated_signature_ok',
        );
      }

      final successCallback = ((JSString paymentId, JSString returnedOrderId, JSString signature) {
        if (!completer.isCompleted) {
          completer.complete(RazorpaySuccessResult(
            paymentId: paymentId.toDart,
            orderId: returnedOrderId.toDart.isNotEmpty ? returnedOrderId.toDart : orderId,
            signature: signature.toDart,
          ));
        }
      }).toJS;

      final dismissCallback = (() {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      }).toJS;

      final failureCallback = ((JSAny error) {
        if (!completer.isCompleted) {
          completer.completeError(Exception('Payment failed: $error'));
        }
      }).toJS;

      globalContext.callMethod(
        'launchRazorpayCheckout'.toJS,
        jsonEncode(options).toJS,
        successCallback,
        dismissCallback,
        failureCallback,
      );
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete(RazorpaySuccessResult(
          paymentId: 'pay_sim_${DateTime.now().millisecondsSinceEpoch}',
          orderId: orderId,
          signature: 'simulated_signature_ok',
        ));
      }
    }

    return completer.future;
  }
}
