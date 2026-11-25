import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/payment/razorpay_payment_gateway.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/auth_state.dart';
import '../../data/models/cart_state.dart';
import '../../data/services/checkout_service.dart';
import '../orders/my_orders_view.dart';
import '../widgets/app_product_image.dart';
import '../widgets/auth_modal.dart';

class CheckoutView extends StatefulWidget {
  final CheckoutService? checkoutService;
  final RazorpayPaymentGateway? paymentGateway;

  const CheckoutView({
    super.key,
    this.checkoutService,
    this.paymentGateway,
  });

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  late final CheckoutService _checkoutService;
  late final RazorpayPaymentGateway _paymentGateway;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _villageController = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  String _paymentMethod = 'PREPAID'; // PREPAID or PARTIAL
  final double _partialAdvancePercentage = 10.0;

  bool _isCheckingServiceability = false;
  ShiprocketServiceabilityResult? _serviceabilityResult;
  String? _serviceabilityError;

  bool _isProcessingPayment = false;
  List<OrderConfirmationResult>? _confirmedOrders;
  String? _orderErrorMessage;

  @override
  void initState() {
    super.initState();
    _checkoutService = widget.checkoutService ?? CheckoutService();
    _paymentGateway = widget.paymentGateway ?? RazorpayPaymentGateway.instance;

    final user = AuthController.instance.currentUser;
    if (user != null) {
      _nameController.text = user.name ?? 'Farmer Customer';
      _phoneController.text = user.phoneNumber;
      if (user.pinCode != null && user.pinCode!.isNotEmpty) {
        _pincodeController.text = user.pinCode!;
        _checkPincodeServiceability(user.pinCode!);
      }
      if (user.villageOrTown != null) _villageController.text = user.villageOrTown!;
      if (user.addressLine1 != null) _address2Controller.text = user.addressLine1!;
      if (user.talukaOrTehsil != null) _cityController.text = user.talukaOrTehsil!;
      if (user.state != null) _stateController.text = user.state!;
    } else {
      _phoneController.text = '9098544263';
      _nameController.text = 'Kisan Customer';
      _stateController.text = 'Madhya Pradesh';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pincodeController.dispose();
    _villageController.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _checkPincodeServiceability(String pin) async {
    final cleanPin = pin.trim();
    if (cleanPin.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(cleanPin)) {
      return;
    }

    setState(() {
      _isCheckingServiceability = true;
      _serviceabilityError = null;
    });

    try {
      final res = await _checkoutService.checkServiceability(cleanPin);
      if (mounted) {
        setState(() {
          _serviceabilityResult = res;
          _isCheckingServiceability = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _serviceabilityError = 'Unable to check courier serviceability';
          _isCheckingServiceability = false;
        });
      }
    }
  }

  double _calculateAmountToPayNow(double totalCartAmount) {
    if (_paymentMethod == 'PREPAID') {
      return totalCartAmount;
    } else {
      return (totalCartAmount * (_partialAdvancePercentage / 100.0));
    }
  }

  Future<void> _handlePlaceOrderAndPay() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!AuthController.instance.isLoggedIn) {
      showAuthModal(context);
      return;
    }

    final cart = CartController.instance;
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty. Add products to checkout.')),
      );
      return;
    }

    setState(() {
      _isProcessingPayment = true;
      _orderErrorMessage = null;
    });

    try {
      final cartSyncPayload = cart.items.map((item) {
        return {
          'variantId': item.variant.id,
          'quantity': item.quantity,
        };
      }).toList();

      // 1. Initiate Payment with backend (creates Razorpay order and syncs cart)
      final initData = await _checkoutService.initiatePayment(
        paymentMethod: _paymentMethod,
        advancePercentage: _paymentMethod == 'PARTIAL' ? _partialAdvancePercentage : null,
        cartItems: cartSyncPayload,
      );

      // 2. Open Razorpay Checkout modal (Web / Gateway)
      final paymentResult = await _paymentGateway.openCheckout(
        keyId: initData.keyId,
        orderId: initData.razorpayOrderId,
        amountPaise: initData.amountPaise,
        currency: initData.currency,
        name: 'EBS BioCrop Science',
        description: _paymentMethod == 'PREPAID'
            ? 'Complete Order Payment'
            : 'Partial Advance Payment (${_partialAdvancePercentage.toInt()}%)',
        prefillContact: _phoneController.text.trim(),
        prefillName: _nameController.text.trim(),
        prefillEmail: initData.prefillEmail,
      );

      if (paymentResult == null) {
        // User dismissed checkout modal
        if (mounted) {
          setState(() {
            _isProcessingPayment = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment cancelled. You can retry anytime.')),
          );
        }
        return;
      }

      // 3. Confirm order with backend & trigger Shiprocket logistics
      final shippingAddress = {
        'name': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'villageArea': _villageController.text.trim(),
        'address2': _address2Controller.text.trim(),
        'cityTehsil': _cityController.text.trim(),
        'district': _cityController.text.trim(),
        'state': _stateController.text.trim().isNotEmpty ? _stateController.text.trim() : 'Madhya Pradesh',
        'pincode': _pincodeController.text.trim(),
        'country': 'India',
      };

      final confirmedList = await _checkoutService.confirmOrder(
        razorpayOrderId: paymentResult.orderId,
        razorpayPaymentId: paymentResult.paymentId,
        razorpaySignature: paymentResult.signature,
        paymentMethod: _paymentMethod,
        advancePercentage: _paymentMethod == 'PARTIAL' ? _partialAdvancePercentage : null,
        shippingAddress: shippingAddress,
      );

      // 4. Clear local cart and show success confirmation screen
      cart.clear();

      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
          _confirmedOrders = confirmedList;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
          _orderErrorMessage = e.toString().replaceAll('Exception:', '').trim();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_confirmedOrders != null) {
      return _buildSuccessScreen(_confirmedOrders!);
    }

    final cart = CartController.instance;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Text(
              'Secure Checkout',
              style: GoogleFonts.mukta(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_rounded, size: 12, color: Color(0xFF2563EB)),
                  const SizedBox(width: 4),
                  Text(
                    'Razorpay & Shiprocket Protected',
                    style: GoogleFonts.mukta(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 48.0 : 16.0,
            vertical: 24.0,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildFormAndPaymentSection(cart)),
                        const SizedBox(width: 32),
                        Expanded(flex: 2, child: _buildOrderSummaryCard(cart)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildFormAndPaymentSection(cart),
                        const SizedBox(height: 24),
                        _buildOrderSummaryCard(cart),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormAndPaymentSection(CartController cart) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_orderErrorMessage != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _orderErrorMessage!,
                      style: GoogleFonts.mukta(
                        fontSize: 13,
                        color: const Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 1. Delivery Address Card
          _buildDeliveryAddressCard(),
          const SizedBox(height: 24),

          // 2. Payment Method Card
          _buildPaymentMethodCard(cart),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.location_on_rounded, color: AppColors.primaryGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1. Farm Delivery Address',
                      style: GoogleFonts.mukta(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Where should Shiprocket couriers deliver your farm inputs?',
                      style: GoogleFonts.mukta(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),

          // Name and Phone Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'e.g. Ramesh Patel',
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone / WhatsApp *',
                    hintText: '10-digit number',
                    prefixIcon: Icon(Icons.phone_outlined, size: 20),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Phone is required';
                    if (v.trim().length != 10) return 'Must be 10 digits';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pincode with live Shiprocket Serviceability
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Delivery Pincode *',
                    hintText: '6-digit PIN',
                    counterText: '',
                    prefixIcon: const Icon(Icons.pin_drop_outlined, size: 20),
                    border: const OutlineInputBorder(),
                    isDense: true,
                    suffixIcon: _isCheckingServiceability
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                  ),
                  onChanged: (val) {
                    if (val.trim().length == 6) {
                      _checkPincodeServiceability(val.trim());
                    }
                  },
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'PIN required';
                    if (v.trim().length != 6) return 'Must be 6 digits';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _villageController,
                  decoration: const InputDecoration(
                    labelText: 'Village / Farm Area / Locality *',
                    hintText: 'e.g. Village Kolar, Farm Post 4',
                    prefixIcon: Icon(Icons.home_work_outlined, size: 20),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Village/Locality is required' : null,
                ),
              ),
            ],
          ),

          // Shiprocket Serviceability Status Badge
          if (_serviceabilityError != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFDC2626)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _serviceabilityError!,
                      style: GoogleFonts.mukta(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_serviceabilityResult != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _serviceabilityResult!.serviceable
                    ? const Color(0xFFF0FDF4)
                    : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _serviceabilityResult!.serviceable
                      ? const Color(0xFFBBF7D0)
                      : const Color(0xFFFECACA),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _serviceabilityResult!.serviceable
                        ? Icons.check_circle_rounded
                        : Icons.warning_amber_rounded,
                    size: 16,
                    color: _serviceabilityResult!.serviceable
                        ? AppColors.primaryGreen
                        : const Color(0xFFDC2626),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _serviceabilityResult!.serviceable
                          ? 'Courier Available: ${_serviceabilityResult!.courierName} • Delivery in ${_serviceabilityResult!.estimatedDeliveryDays} days (Shiprocket Verified)'
                          : 'Pincode not reachable by standard couriers',
                      style: GoogleFonts.mukta(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _serviceabilityResult!.serviceable
                            ? const Color(0xFF166534)
                            : const Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Landmark / Address 2
          TextFormField(
            controller: _address2Controller,
            decoration: const InputDecoration(
              labelText: 'Nearby Landmark / Depot Road (Optional)',
              hintText: 'e.g. Opposite Primary School, Near Canal Gate',
              prefixIcon: Icon(Icons.navigation_outlined, size: 20),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 16),

          // City/Tehsil and State Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City / Tehsil *',
                    hintText: 'e.g. Huzur',
                    prefixIcon: Icon(Icons.location_city_outlined, size: 20),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'City/Tehsil is required' : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextFormField(
                  controller: _stateController,
                  decoration: const InputDecoration(
                    labelText: 'State *',
                    hintText: 'e.g. Madhya Pradesh',
                    prefixIcon: Icon(Icons.map_outlined, size: 20),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'State is required' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(CartController cart) {
    final total = cart.subtotal;
    final advanceDue = _calculateAmountToPayNow(total);
    final codBalance = total - advanceDue;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.payment_rounded, color: Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2. Select Payment Option',
                      style: GoogleFonts.mukta(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Powered by Razorpay • UPI, Cards, Netbanking & Partial Payment',
                      style: GoogleFonts.mukta(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),

          // Option A: 100% Prepaid via Razorpay
          InkWell(
            onTap: () {
              setState(() {
                _paymentMethod = 'PREPAID';
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _paymentMethod == 'PREPAID' ? const Color(0xFFF0FDF4) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _paymentMethod == 'PREPAID' ? AppColors.primaryGreen : AppColors.border,
                  width: _paymentMethod == 'PREPAID' ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _paymentMethod == 'PREPAID' ? AppColors.primaryGreen : AppColors.textMuted,
                        width: 2,
                      ),
                    ),
                    child: _paymentMethod == 'PREPAID'
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              'Pay Online (100% Prepaid via Razorpay)',
                              style: GoogleFonts.mukta(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'RECOMMENDED',
                                style: GoogleFonts.mukta(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'UPI (Google Pay, PhonePe, Paytm), Debit/Credit Cards, Netbanking. Zero COD fees & priority dispatch.',
                          style: GoogleFonts.mukta(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${total.toStringAsFixed(0)}',
                    style: GoogleFonts.mukta(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Option B: Partial Advance Payment via Razorpay
          InkWell(
            onTap: () {
              setState(() {
                _paymentMethod = 'PARTIAL';
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _paymentMethod == 'PARTIAL' ? const Color(0xFFFFFBEB) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _paymentMethod == 'PARTIAL' ? const Color(0xFFD97706) : AppColors.border,
                  width: _paymentMethod == 'PARTIAL' ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _paymentMethod == 'PARTIAL' ? const Color(0xFFD97706) : AppColors.textMuted,
                            width: 2,
                          ),
                        ),
                        child: _paymentMethod == 'PARTIAL'
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Partial Advance via Razorpay + Remaining on Delivery',
                              style: GoogleFonts.mukta(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pay a token booking advance online now to book stock; pay balance in cash/UPI to courier at farm gate.',
                              style: GoogleFonts.mukta(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (_paymentMethod == 'PARTIAL') ...[
                    const Divider(height: 20),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Text(
                            'Pay 10% Advance Online Now: ₹${advanceDue.toStringAsFixed(0)}',
                            style: GoogleFonts.mukta(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                          Text(
                            'Pay 90% on Delivery (COD): ₹${codBalance.toStringAsFixed(0)}',
                            style: GoogleFonts.mukta(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(CartController cart) {
    final total = cart.subtotal;
    final totalMrp = cart.totalMrp;
    final savings = cart.totalSavings;
    final amountToPayNow = _calculateAmountToPayNow(total);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Order Items (${cart.totalCount})',
            style: GoogleFonts.mukta(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Divider(height: 20),

          // Items List
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: cart.items.length,
              separatorBuilder: (_, _) => const Divider(height: 14),
              itemBuilder: (ctx, idx) {
                final item = cart.items[idx];
                return Row(
                  children: [
                    AppProductImage(
                      imageUrl: item.product.imageUrl,
                      width: 48,
                      height: 48,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.title,
                            style: GoogleFonts.mukta(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${item.variant.label} × ${item.quantity}',
                            style: GoogleFonts.mukta(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${item.totalRate.toStringAsFixed(0)}',
                      style: GoogleFonts.mukta(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 24),

          // Price Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('Total MRP', style: GoogleFonts.mukta(fontSize: 13, color: AppColors.textSecondary))),
              Text('₹${totalMrp.toStringAsFixed(0)}', style: GoogleFonts.mukta(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          if (savings > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('Agri Discount', style: GoogleFonts.mukta(fontSize: 13, color: AppColors.primaryGreen))),
                Text('-₹${savings.toStringAsFixed(0)}', style: GoogleFonts.mukta(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryGreen)),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('Express Logistics (Shiprocket)', style: GoogleFonts.mukta(fontSize: 13, color: AppColors.textSecondary))),
              Text('FREE', style: GoogleFonts.mukta(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryGreen)),
            ],
          ),
          const Divider(height: 20),

          // Grand Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Total Order Value',
                  style: GoogleFonts.mukta(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
              Text(
                '₹${total.toStringAsFixed(0)}',
                style: GoogleFonts.mukta(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryGreen),
              ),
            ],
          ),

          if (_paymentMethod == 'PARTIAL') ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Amount Due Now (${_partialAdvancePercentage.toInt()}%)',
                    style: GoogleFonts.mukta(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFD97706)),
                  ),
                ),
                Text(
                  '₹${amountToPayNow.toStringAsFixed(0)}',
                  style: GoogleFonts.mukta(fontSize: 15, fontWeight: FontWeight.w800, color: const Color(0xFFD97706)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Balance on Delivery (COD)',
                    style: GoogleFonts.mukta(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ),
                Text(
                  '₹${(total - amountToPayNow).clamp(0, total).toStringAsFixed(0)}',
                  style: GoogleFonts.mukta(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),

          // Place Order Button
          ElevatedButton(
            onPressed: _isProcessingPayment ? null : _handlePlaceOrderAndPay,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: _isProcessingPayment
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Processing Payment...',
                        style: GoogleFonts.mukta(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
                  )
                : Text(
                    'PAY ₹${amountToPayNow.toStringAsFixed(0)} VIA RAZORPAY',
                    style: GoogleFonts.mukta(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
          const SizedBox(height: 14),

          // Trust assurance icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '100% Genuine Agri-inputs • Secure Razorpay Payment',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.mukta(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen(List<OrderConfirmationResult> orders) {
    final firstOrder = orders.first;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Order Placed Successfully',
          style: GoogleFonts.mukta(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    offset: Offset(0, 4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primaryGreen,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Kisan Bhai, Your Order is Confirmed!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.mukta(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thank you for trusting EBS Essential BioCrop Science. Your order has been registered and dispatched to Shiprocket for rapid express shipping to your farm.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.mukta(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const Divider(height: 36),

                  // Order details card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        _buildSuccessRow('Order Number', firstOrder.orderNumber),
                        const Divider(height: 16),
                        _buildSuccessRow('Payment Method', firstOrder.paymentMethod),
                        const Divider(height: 16),
                        _buildSuccessRow('Payment Status', firstOrder.paymentStatus),
                        const Divider(height: 16),
                        _buildSuccessRow('Amount Paid Online', '₹${firstOrder.amountPaid.toStringAsFixed(0)}'),
                        if (firstOrder.courierName != null) ...[
                          const Divider(height: 16),
                          _buildSuccessRow('Logistics Partner', firstOrder.courierName!),
                        ],
                        if (firstOrder.awbCode != null) ...[
                          const Divider(height: 16),
                          _buildSuccessRow('Shiprocket AWB', firstOrder.awbCode!),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      if (firstOrder.trackingUrl != null && firstOrder.trackingUrl!.isNotEmpty) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final uri = Uri.parse(firstOrder.trackingUrl!);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            },
                            icon: const Icon(Icons.local_shipping_outlined, size: 16),
                            label: Text(
                              'Track on Shiprocket',
                              style: GoogleFonts.mukta(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryGreen,
                              side: const BorderSide(color: AppColors.primaryGreen),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const MyOrdersView()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: Text(
                            'View My Orders',
                            style: GoogleFonts.mukta(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.mukta(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: GoogleFonts.mukta(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
