import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seller_website/core/payment/razorpay_payment_gateway.dart';
import 'package:seller_website/data/models/auth_state.dart';
import 'package:seller_website/data/models/cart_state.dart';
import 'package:seller_website/data/models/catalog_models.dart';
import 'package:seller_website/data/services/checkout_service.dart';
import 'package:seller_website/presentation/checkout/checkout_view.dart';

class MockCheckoutService extends CheckoutService {
  bool serviceabilityCalled = false;
  bool initiatePaymentCalled = false;
  bool confirmOrderCalled = false;

  @override
  Future<ShiprocketServiceabilityResult> checkServiceability(String pincode) async {
    serviceabilityCalled = true;
    return ShiprocketServiceabilityResult(
      pincode: pincode,
      serviceable: true,
      estimatedDeliveryDays: 3,
      courierName: 'Delhivery Surface (Shiprocket)',
      shippingCharge: 0.0,
      message: 'Delivery available in 3 business days',
    );
  }

  @override
  Future<RazorpayPaymentInitData> initiatePayment({
    required String paymentMethod,
    double? advancePercentage,
    List<Map<String, dynamic>>? cartItems,
  }) async {
    initiatePaymentCalled = true;
    return const RazorpayPaymentInitData(
      razorpayOrderId: 'order_test_998877',
      keyId: 'rzp_test_key_123',
      amountPaise: 51000,
      amountInRupees: 510.0,
      currency: 'INR',
      totalCartAmount: 510.0,
      advancePercentage: 100.0,
      prefillName: 'Ramesh Patel',
      prefillContact: '9098544263',
      prefillEmail: 'ramesh@example.com',
    );
  }

  @override
  Future<List<OrderConfirmationResult>> confirmOrder({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String paymentMethod,
    double? advancePercentage,
    required Map<String, dynamic> shippingAddress,
  }) async {
    confirmOrderCalled = true;
    return const [
      OrderConfirmationResult(
        checkoutGroupId: 'grp_test_1',
        orderId: 'ord_test_1',
        orderNumber: 'ORD-EBS-2026-9901',
        status: 'ORDERED',
        paymentMethod: 'PREPAID',
        paymentStatus: 'PAID',
        amountPaid: 510.0,
        totalAmount: 510.0,
        awbCode: 'SRK9948201IN',
        courierName: 'Delhivery Surface (Shiprocket)',
        trackingUrl: 'https://shiprocket.co/tracking/SRK9948201IN',
        shipmentStatus: 'READY_FOR_PICKUP',
      ),
    ];
  }
}

class MockPaymentGateway implements RazorpayPaymentGateway {
  bool checkoutOpened = false;

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
    checkoutOpened = true;
    return RazorpaySuccessResult(
      paymentId: 'pay_test_succ_12345',
      orderId: orderId,
      signature: 'sig_mock_signature_abc',
    );
  }
}

void main() {
  setUp(() {
    CartController.instance.clear();
    // Add sample item to cart
    final sampleProd = ProductItem.sampleProducts.first;
    CartController.instance.addItem(
      sampleProd,
      sampleProd.variants.isNotEmpty ? sampleProd.variants.first : sampleProd.defaultVariant,
      1,
    );
  });

  testWidgets('CheckoutView renders address form, payment options, and summary', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockService = MockCheckoutService();
    final mockGateway = MockPaymentGateway();

    await tester.pumpWidget(
      MaterialApp(
        home: CheckoutView(
          checkoutService: mockService,
          paymentGateway: mockGateway,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Secure Checkout'), findsOneWidget);
    expect(find.text('1. Farm Delivery Address'), findsOneWidget);
    expect(find.text('2. Select Payment Option'), findsOneWidget);
    expect(find.text('Pay Online (100% Prepaid via Razorpay)'), findsOneWidget);
    expect(find.text('Partial Advance via Razorpay + Remaining on Delivery'), findsOneWidget);
    expect(find.textContaining('Shiprocket Protected'), findsOneWidget);
  });

  testWidgets('Entering 6-digit pincode triggers Shiprocket serviceability check', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockService = MockCheckoutService();
    final mockGateway = MockPaymentGateway();

    await tester.pumpWidget(
      MaterialApp(
        home: CheckoutView(
          checkoutService: mockService,
          paymentGateway: mockGateway,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final pinField = find.widgetWithText(TextFormField, 'Delivery Pincode *');
    expect(pinField, findsOneWidget);

    await tester.enterText(pinField, '462001');
    await tester.pumpAndSettle();

    expect(mockService.serviceabilityCalled, isTrue);
    expect(find.textContaining('Delhivery Surface (Shiprocket)'), findsOneWidget);
  });

  testWidgets('Selecting Partial Payment allows selecting advance percentage', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockService = MockCheckoutService();
    final mockGateway = MockPaymentGateway();

    await tester.pumpWidget(
      MaterialApp(
        home: CheckoutView(
          checkoutService: mockService,
          paymentGateway: mockGateway,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on Partial Payment card
    final partialCard = find.text('Partial Advance via Razorpay + Remaining on Delivery');
    await tester.tap(partialCard);
    await tester.pumpAndSettle();

    expect(find.text('Choose Advance Amount to Pay Now:'), findsOneWidget);
    expect(find.textContaining('Pay Online Now:'), findsOneWidget);
    expect(find.textContaining('Pay to Courier on Delivery:'), findsOneWidget);
  });

  testWidgets('Placing order opens Razorpay, confirms order and displays Shiprocket AWB', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Ensure user is simulated as logged in
    AuthController.instance.setUserForTest(const UserModel(
      phoneNumber: '9098544263',
      name: 'Ramesh Patel',
      pinCode: '462001',
      villageOrTown: 'Gram Kolar',
      addressLine1: 'Near School',
      talukaOrTehsil: 'Huzur',
      state: 'Madhya Pradesh',
    ));

    final mockService = MockCheckoutService();
    final mockGateway = MockPaymentGateway();

    await tester.pumpWidget(
      MaterialApp(
        home: CheckoutView(
          checkoutService: mockService,
          paymentGateway: mockGateway,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Click Pay via Razorpay button
    final payBtn = find.textContaining('PAY ₹');
    expect(payBtn, findsOneWidget);

    await tester.tap(payBtn);
    await tester.pumpAndSettle();

    expect(mockService.initiatePaymentCalled, isTrue);
    expect(mockGateway.checkoutOpened, isTrue);
    expect(mockService.confirmOrderCalled, isTrue);

    // Verify Success Screen
    expect(find.text('Kisan Bhai, Your Order is Confirmed!'), findsOneWidget);
    expect(find.text('ORD-EBS-2026-9901'), findsOneWidget);
    expect(find.text('SRK9948201IN'), findsOneWidget);
    expect(find.text('Delhivery Surface (Shiprocket)'), findsOneWidget);
    expect(find.text('Track on Shiprocket'), findsOneWidget);
  });
}
