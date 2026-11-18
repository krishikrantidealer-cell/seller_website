// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import 'fastrr_checkout_gateway.dart';

FastrrCheckoutGateway createFastrrGateway() => WebFastrrCheckoutGateway();

class WebFastrrCheckoutGateway implements FastrrCheckoutGateway {
  @override
  Future<FastrrCheckoutResult> openCheckout({
    required String storeKey,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    String? customerPhone,
    String? customerName,
  }) async {
    final completer = Completer<FastrrCheckoutResult>();

    String? checkoutToken;
    String? apiKey;
    String? storeUrl;
    try {
      final tokenUri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.fastrrCheckoutToken}');
      final tokenReqItems = items.map((e) => {
        'productId': e['productId'] ?? e['id'] ?? '',
        if (e['variantId'] != null) 'variantId': e['variantId'],
        'quantity': e['quantity'] ?? 1,
      }).toList();

      final tokenResp = await http
          .post(
            tokenUri,
            headers: const {'Content-Type': 'application/json', 'Accept': 'application/json'},
            body: jsonEncode({
              'items': tokenReqItems,
              if (Uri.base.hasAuthority &&
                  (Uri.base.host == 'localhost' || Uri.base.host == '127.0.0.1'))
                'redirectUrl': Uri.base.origin,
            }),
          )
          .timeout(const Duration(seconds: 12));

      final decoded = jsonDecode(tokenResp.body);
      if (tokenResp.statusCode < 200 || tokenResp.statusCode >= 300 || decoded is! Map) {
        final msg = (decoded is Map ? decoded['message'] : null)?.toString() ??
            'Failed to initialize Fastrr Checkout (${tokenResp.statusCode}).';
        return FastrrCheckoutResult(success: false, errorMessage: msg);
      }

      final data = decoded['data'];
      if (data is Map) {
        checkoutToken = data['token']?.toString();
        apiKey = data['apiKey']?.toString();
        storeUrl = data['storeUrl']?.toString();
      }
      if (checkoutToken == null || checkoutToken.isEmpty) {
        return const FastrrCheckoutResult(
          success: false,
          errorMessage: 'Backend did not return a valid Fastrr checkout token.',
        );
      }
    } catch (e) {
      return FastrrCheckoutResult(
        success: false,
        errorMessage: 'Unable to reach checkout server: $e',
      );
    }

    final payload = {
      'token': checkoutToken,
      if (apiKey != null && apiKey.isNotEmpty) 'apiKey': apiKey,
      if (storeUrl != null && storeUrl.isNotEmpty) 'storeUrl': storeUrl,
      'storeKey': storeKey,
      'amount': totalAmount,
      'currency': 'INR',
      'items': items,
      if (customerPhone != null && customerPhone.isNotEmpty) 'phone': customerPhone,
      if (customerName != null && customerName.isNotEmpty) 'name': customerName,
    };

    try {
      final hasLauncher = globalContext.has('launchFastrrCheckout');
      if (!hasLauncher) {
        return const FastrrCheckoutResult(
          success: false,
          errorMessage: 'Fastrr Checkout SDK not detected in browser.',
        );
      }

      final successCallback = ((JSString responseJson) {
        final raw = responseJson.toDart;
        unawaited(() async {
          String? orderId;
          try {
            final parsed = jsonDecode(raw);
            final Map<String, dynamic> confirmPayload =
                parsed is Map ? Map<String, dynamic>.from(parsed) : <String, dynamic>{};
            orderId = (confirmPayload['order_id'] ??
                    confirmPayload['orderId'] ??
                    confirmPayload['fastrr_order_id'] ??
                    confirmPayload['id'])
                ?.toString();
            if (confirmPayload['items'] == null && confirmPayload['line_items'] == null) {
              confirmPayload['items'] = items
                  .map((e) => {
                        'productId': e['productId'] ?? e['id'] ?? '',
                        if (e['variantId'] != null) 'variantId': e['variantId'],
                        'quantity': e['quantity'] ?? 1,
                      })
                  .toList();
            }
            if (customerPhone != null &&
                customerPhone.isNotEmpty &&
                confirmPayload['phone'] == null) {
              confirmPayload['phone'] = customerPhone;
            }
            if (customerName != null &&
                customerName.isNotEmpty &&
                confirmPayload['customer_name'] == null) {
              confirmPayload['customer_name'] = customerName;
            }
            if (orderId != null && orderId.isNotEmpty) {
              await http
                  .post(
                    Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.fastrrCheckoutConfirm}'),
                    headers: const {
                      'Content-Type': 'application/json',
                      'Accept': 'application/json',
                    },
                    body: jsonEncode(confirmPayload),
                  )
                  .timeout(const Duration(seconds: 10));
            }
          } catch (_) {}
          if (!completer.isCompleted) {
            completer.complete(FastrrCheckoutResult(
              success: true,
              rawResponse: raw,
            ));
          }
        }());
      }).toJS;

      final dismissCallback = (() {
        if (!completer.isCompleted) {
          completer.complete(const FastrrCheckoutResult(
            success: false,
            errorMessage: 'Checkout dismissed by customer',
          ));
        }
      }).toJS;

      final failureCallback = ((JSString error) {
        if (!completer.isCompleted) {
          completer.complete(FastrrCheckoutResult(
            success: false,
            errorMessage: error.toDart,
          ));
        }
      }).toJS;

      globalContext.callMethod(
        'launchFastrrCheckout'.toJS,
        jsonEncode(payload).toJS,
        successCallback,
        dismissCallback,
        failureCallback,
      );
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete(FastrrCheckoutResult(
          success: false,
          errorMessage: e.toString(),
        ));
      }
    }

    return completer.future;
  }
}
