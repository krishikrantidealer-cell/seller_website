import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/cart/cart_bloc.dart';
import '../../../logic/cart/cart_event.dart';
import '../../../logic/cart/cart_state.dart';

enum PaymentMethod {
  cashOnDelivery('Cash on Delivery (COD)', 'घर पहुँचने पर नकद भुगतान', Icons.payments_outlined),
  upi('UPI (PhonePe, GPay, Paytm, BHIM)', 'तुरंत ऑनलाइन भुगतान - 0% शुल्क', Icons.qr_code_2_rounded),
  kcc('Kisan Credit Card / Rupay Card', 'किसान क्रेडिट कार्ड व बैंक डेबिट कार्ड', Icons.credit_card_rounded),
  whatsapp('Order via WhatsApp', 'व्हाट्सएप कृषि मित्र द्वारा 1-क्लिक ऑर्डर', Icons.chat_bubble_outline_rounded);

  final String title;
  final String subtitle;
  final IconData icon;

  const PaymentMethod(this.title, this.subtitle, this.icon);
}

class FarmerCheckoutModal extends StatefulWidget {
  final CartState cartState;

  const FarmerCheckoutModal({super.key, required this.cartState});

  static Future<void> show(BuildContext context, CartState cartState) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<CartBloc>(),
        child: FarmerCheckoutModal(cartState: cartState),
      ),
    );
  }

  @override
  State<FarmerCheckoutModal> createState() => _FarmerCheckoutModalState();
}

class _FarmerCheckoutModalState extends State<FarmerCheckoutModal> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _villageController = TextEditingController();
  final _tehsilController = TextEditingController();
  final _districtController = TextEditingController();
  final _pincodeController = TextEditingController();

  String _selectedState = 'Maharashtra';
  PaymentMethod _selectedPayment = PaymentMethod.cashOnDelivery;

  bool _isSubmitted = false;
  String _generatedOrderId = '';

  static const List<String> _agriStates = [
    'Andhra Pradesh',
    'Bihar',
    'Chhattisgarh',
    'Gujarat',
    'Haryana',
    'Karnataka',
    'Madhya Pradesh',
    'Maharashtra',
    'Punjab',
    'Rajasthan',
    'Telangana',
    'Uttar Pradesh',
    'West Bengal',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    _tehsilController.dispose();
    _districtController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _placeOrder() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final randomNum = 10000 + Random().nextInt(90000);
    final orderId = 'EBS-OD-$randomNum';

    setState(() {
      _generatedOrderId = orderId;
      _isSubmitted = true;
    });

    // Clear the cart on successful checkout
    context.read<CartBloc>().add(const ClearCart());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.width < 640;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 24,
        vertical: isCompact ? 16 : 28,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
          maxHeight: size.height * 0.92,
        ),
        child: _isSubmitted ? _buildOrderSuccessView(isCompact) : _buildCheckoutFormView(isCompact),
      ),
    );
  }

  Widget _buildCheckoutFormView(bool isCompact) {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 16 : 24,
            vertical: isCompact ? 12 : 16,
          ),
          decoration: const BoxDecoration(
            color: AppColors.forestDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.harvestAmber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farmer Checkout (किसान ऑर्डर)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isCompact ? 15 : 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '100% Genuine Agri-Inputs • Free Pan-India Doorstep Delivery',
                      style: TextStyle(
                        color: AppColors.harvestAmberLight,
                        fontSize: isCompact ? 10.5 : 11.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),

        // Scrollable Body Form
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isCompact ? 16 : 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.paleGreen.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shopping_basket_rounded, color: AppColors.primaryGreen, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Basket Summary: ${widget.cartState.totalCount} item(s)',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.forestDark,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '₹${widget.cartState.subtotal.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.forestDark,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade700,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'किसान बचत: ₹${widget.cartState.totalSavings.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'डिलीवरी: मुफ़्त (FREE)',
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section Title: Delivery Address
                  const Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 18, color: AppColors.primaryGreen),
                      SizedBox(width: 6),
                      Text(
                        '1. Kisan Delivery Address (डिलीवरी पता)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.forestDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Name & Phone
                  _buildResponsiveRow(
                    isCompact: isCompact,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Farmer Full Name (किसान का पूरा नाम) *',
                          hintText: 'e.g. Ramesh Patel',
                          prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Mobile Number (मोबाइल नंबर) *',
                          hintText: '10 digit mobile number',
                          prefixText: '+91 ',
                          prefixIcon: const Icon(Icons.phone_android_rounded, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().length < 10) {
                            return 'Please enter a valid 10-digit mobile number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Village & Tehsil
                  _buildResponsiveRow(
                    isCompact: isCompact,
                    children: [
                      TextFormField(
                        controller: _villageController,
                        decoration: InputDecoration(
                          labelText: 'Village / Gram Panchayat (गाँव / ग्राम पंचायत) *',
                          hintText: 'e.g. Anandpur, Post Kasba',
                          prefixIcon: const Icon(Icons.home_outlined, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your village / locality';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _tehsilController,
                        decoration: InputDecoration(
                          labelText: 'Tehsil / Taluka (तहसील / तालुका)',
                          hintText: 'e.g. Haveli',
                          prefixIcon: const Icon(Icons.map_outlined, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // District, State & Pincode
                  _buildResponsiveRow(
                    isCompact: isCompact,
                    children: [
                      TextFormField(
                        controller: _districtController,
                        decoration: InputDecoration(
                          labelText: 'District (जिला) *',
                          hintText: 'e.g. Nashik',
                          prefixIcon: const Icon(Icons.location_city_rounded, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your district';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: _selectedState,
                        decoration: InputDecoration(
                          labelText: 'State (राज्य) *',
                          prefixIcon: const Icon(Icons.flag_outlined, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: _agriStates.map((state) {
                          return DropdownMenuItem(
                            value: state,
                            child: Text(state, style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedState = val);
                        },
                      ),
                      TextFormField(
                        controller: _pincodeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: 'Pincode (पिन कोड) *',
                          hintText: '6 Digits',
                          counterText: '',
                          prefixIcon: const Icon(Icons.pin_drop_outlined, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().length != 6) {
                            return 'Enter 6-digit PIN';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Section Title: Payment Methods
                  const Row(
                    children: [
                      Icon(Icons.payment_rounded, size: 18, color: AppColors.primaryGreen),
                      SizedBox(width: 6),
                      Text(
                        '2. Payment Option (भुगतान का प्रकार)',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.forestDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Payment Method List
                  ...PaymentMethod.values.map((method) {
                    final isSelected = _selectedPayment == method;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.paleGreen.withValues(alpha: 0.5) : Colors.white,
                        border: Border.all(
                          color: isSelected ? AppColors.primaryGreen : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        onTap: () => setState(() => _selectedPayment = method),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                method.icon,
                                color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                                size: 24,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      method.title,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        color: isSelected ? AppColors.forestDark : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      method.subtitle,
                                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                                color: isSelected ? AppColors.primaryGreen : AppColors.textMuted,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  // Trust assurance
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_user_outlined, size: 18, color: AppColors.forestDark),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'EBS BioCrop Trust: 100% Original Products directly from lab. 7-Day Doorstep Replacement Guarantee.',
                            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Action Buttons Bar
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 16 : 24,
            vertical: 14,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: Row(
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Basket', style: TextStyle(color: AppColors.textSecondary)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandRed,
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 18 : 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: Text(
                  _selectedPayment == PaymentMethod.whatsapp
                      ? 'Send Order to WhatsApp'
                      : 'Confirm Order (₹${widget.cartState.subtotal.toStringAsFixed(0)})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSuccessView(bool isCompact) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Success Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: AppColors.forestDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF4ADE80), size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Order Placed Successfully! (ऑर्डर सफल)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),

        // Body
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isCompact ? 16 : 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.paleGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: AppColors.primaryGreen,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'बधाई हो ${_nameController.text.trim()} जी!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'आपका कृषि ऑर्डर सफलतापूर्वक दर्ज कर लिया गया है।',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Order Details Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Order Reference ID:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(
                            _generatedOrderId,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.forestDark),
                          ),
                        ],
                      ),
                      const Divider(height: 14, color: AppColors.border),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Payable:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(
                            '₹${widget.cartState.subtotal.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primaryGreen),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Payment Mode:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(
                            _selectedPayment.title,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 14, color: AppColors.border),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Dispatch To:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${_villageController.text.trim()}, ${_tehsilController.text.trim().isNotEmpty ? "${_tehsilController.text.trim()}, " : ""}${_districtController.text.trim()}, $_selectedState - ${_pincodeController.text.trim()}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Dispatch timeline badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.paleGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.local_shipping_outlined, color: AppColors.primaryGreen, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Doorstep Delivery in 3-5 days. Tracking link will be sent via SMS to your registered mobile number.',
                          style: TextStyle(fontSize: 11.5, color: AppColors.forestDark, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Return & Help actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.support_agent_rounded, size: 16),
                        label: const Text('Helpline 1800-203-1425', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Continue Shopping (जारी रखें)', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponsiveRow({
    required bool isCompact,
    required List<Widget> children,
  }) {
    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            children[i],
          ],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}
