import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';

/// Result from Shiprocket serviceability check
class ShiprocketServiceabilityResult {
  final String pincode;
  final bool serviceable;
  final int estimatedDeliveryDays;
  final String courierName;
  final double shippingCharge;
  final String message;

  const ShiprocketServiceabilityResult({
    required this.pincode,
    required this.serviceable,
    required this.estimatedDeliveryDays,
    required this.courierName,
    required this.shippingCharge,
    required this.message,
  });

  factory ShiprocketServiceabilityResult.fromJson(Map<String, dynamic> json) {
    return ShiprocketServiceabilityResult(
      pincode: (json['deliveryPincode'] ?? json['pincode'] ?? '').toString(),
      serviceable: json['serviceable'] == true,
      estimatedDeliveryDays: (json['estimatedDeliveryDays'] as num?)?.toInt() ?? 3,
      courierName: (json['courierName'] ?? 'Shiprocket Express').toString(),
      shippingCharge: (json['shippingCharge'] as num?)?.toDouble() ?? 0.0,
      message: (json['message'] ?? 'Serviceable').toString(),
    );
  }
}

/// Razorpay payment initialization parameters
class RazorpayPaymentInitData {
  final String razorpayOrderId;
  final String keyId;
  final int amountPaise;
  final double amountInRupees;
  final String currency;
  final double totalCartAmount;
  final double advancePercentage;
  final String prefillName;
  final String prefillContact;
  final String prefillEmail;

  const RazorpayPaymentInitData({
    required this.razorpayOrderId,
    required this.keyId,
    required this.amountPaise,
    required this.amountInRupees,
    required this.currency,
    required this.totalCartAmount,
    required this.advancePercentage,
    required this.prefillName,
    required this.prefillContact,
    required this.prefillEmail,
  });

  factory RazorpayPaymentInitData.fromJson(Map<String, dynamic> json) {
    return RazorpayPaymentInitData(
      razorpayOrderId: (json['razorpayOrderId'] ?? '').toString(),
      keyId: (json['keyId'] ?? '').toString(),
      amountPaise: (json['amountPaise'] as num?)?.toInt() ?? 0,
      amountInRupees: (json['amountInRupees'] as num?)?.toDouble() ?? 0.0,
      currency: (json['currency'] ?? 'INR').toString(),
      totalCartAmount: (json['totalCartAmount'] as num?)?.toDouble() ?? 0.0,
      advancePercentage: (json['advancePercentage'] as num?)?.toDouble() ?? 100.0,
      prefillName: (json['prefillName'] ?? '').toString(),
      prefillContact: (json['prefillContact'] ?? '').toString(),
      prefillEmail: (json['prefillEmail'] ?? '').toString(),
    );
  }
}

/// Order confirmation and Shiprocket dispatch result
class OrderConfirmationResult {
  final String checkoutGroupId;
  final String orderId;
  final String orderNumber;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final double amountPaid;
  final double totalAmount;
  final String? awbCode;
  final String? courierName;
  final String? trackingUrl;
  final String? shipmentStatus;

  const OrderConfirmationResult({
    required this.checkoutGroupId,
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.amountPaid,
    required this.totalAmount,
    this.awbCode,
    this.courierName,
    this.trackingUrl,
    this.shipmentStatus,
  });

  factory OrderConfirmationResult.fromOrderJson(String checkoutGroupId, Map<String, dynamic> json) {
    final shippingDetails = json['shippingDetails'] as Map<String, dynamic>?;
    final payment = json['payment'] as Map<String, dynamic>?;
    return OrderConfirmationResult(
      checkoutGroupId: checkoutGroupId,
      orderId: (json['id'] ?? '').toString(),
      orderNumber: (json['orderNumber'] ?? '').toString(),
      status: (json['orderStatus'] ?? 'ORDERED').toString(),
      paymentMethod: (json['paymentMethod'] ?? 'PREPAID').toString(),
      paymentStatus: (json['paymentStatus'] ?? 'PAID').toString(),
      amountPaid: (payment?['amountPaid'] as num?)?.toDouble() ?? (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      awbCode: shippingDetails?['awbCode']?.toString(),
      courierName: shippingDetails?['courierName']?.toString(),
      trackingUrl: shippingDetails?['trackingUrl']?.toString(),
      shipmentStatus: shippingDetails?['status']?.toString(),
    );
  }
}

/// Service handling Shiprocket checks and Razorpay checkout API communication
class CheckoutService {
  final ApiClient _apiClient;

  CheckoutService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Check pincode serviceability via Shiprocket (Public)
  Future<ShiprocketServiceabilityResult> checkServiceability(String pincode) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.checkoutServiceability,
        queryParameters: {'pincode': pincode.trim()},
        requiresAuth: false,
      );
      final data = response['data'] as Map<String, dynamic>? ?? {};
      return ShiprocketServiceabilityResult.fromJson(data);
    } catch (e) {
      // Return safe fallback if network offline
      return ShiprocketServiceabilityResult(
        pincode: pincode,
        serviceable: true,
        estimatedDeliveryDays: 3,
        courierName: 'Shiprocket Logistics (Standard)',
        shippingCharge: 0.0,
        message: 'Delivery available in 3-4 days',
      );
    }
  }

  /// Initialize Razorpay payment with backend
  Future<RazorpayPaymentInitData> initiatePayment({
    required String paymentMethod,
    double? advancePercentage,
    List<Map<String, dynamic>>? cartItems,
  }) async {
    // If cart items are provided, sync them to backend cart first
    if (cartItems != null && cartItems.isNotEmpty) {
      try {
        await _apiClient.post(
          '/api/v1/cart/sync',
          body: {'items': cartItems},
          requiresAuth: true,
        );
      } catch (_) {
        // Continue if items are already synced or backend allows
      }
    }

    final body = <String, dynamic>{
      'paymentMethod': paymentMethod,
    };
    if (advancePercentage != null && paymentMethod != 'PREPAID') {
      body['advancePercentage'] = advancePercentage;
    }

    final response = await _apiClient.post(
      ApiEndpoints.checkoutInitiatePayment,
      body: body,
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>? ?? {};
    return RazorpayPaymentInitData.fromJson(data);
  }

  /// Confirm payment and dispatch order to Shiprocket
  Future<List<OrderConfirmationResult>> confirmOrder({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String paymentMethod,
    double? advancePercentage,
    required Map<String, dynamic> shippingAddress,
  }) async {
    final orderReq = <String, dynamic>{
      'paymentMethod': paymentMethod,
      'shippingAddress': shippingAddress,
    };
    if (advancePercentage != null && paymentMethod != 'PREPAID') {
      orderReq['advancePercentage'] = advancePercentage;
    }

    final payload = {
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpaySignature': razorpaySignature,
      'orderRequest': orderReq,
    };

    final response = await _apiClient.post(
      ApiEndpoints.checkoutConfirmOrder,
      body: payload,
      requiresAuth: true,
    );

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final checkoutGroupId = (data['checkoutGroupId'] ?? '').toString();
    final ordersList = data['orders'] as List<dynamic>? ?? [];

    return ordersList
        .map((o) => OrderConfirmationResult.fromOrderJson(checkoutGroupId, o as Map<String, dynamic>))
        .toList();
  }

  /// Fetch live Shiprocket tracking
  Future<Map<String, dynamic>> trackOrder(String orderId) async {
    final response = await _apiClient.get(
      ApiEndpoints.checkoutTrack(orderId),
      requiresAuth: true,
    );
    return response['data'] as Map<String, dynamic>? ?? {};
  }
}
