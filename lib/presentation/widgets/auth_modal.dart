import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/auth_state.dart';

/// Opens the responsive Phone + OTP Login modal or User Account menu
void showAuthModal(BuildContext context) {
  final isMobile = MediaQuery.sizeOf(context).width < 650;

  if (isMobile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AuthModalWrapper(isMobile: true),
    );
  } else {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: _AuthModalWrapper(isMobile: false),
      ),
    );
  }
}

class _AuthModalWrapper extends StatelessWidget {
  final bool isMobile;

  const _AuthModalWrapper({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AuthController.instance,
      builder: (context, _) {
        final auth = AuthController.instance;

        Widget content;
        if (auth.isLoggedIn) {
          content = _AccountProfileView(isMobile: isMobile);
        } else if (auth.pendingPhone != null) {
          content = _OtpVerificationView(isMobile: isMobile);
        } else {
          content = _PhoneInputView(isMobile: isMobile);
        }

        if (isMobile) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    content,
                  ],
                ),
              ),
            ),
          );
        }

        return Container(
          width: 460,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            child: content,
          ),
        );
      },
    );
  }
}

// ============================================================================
// STEP 1: PHONE NUMBER INPUT VIEW
// ============================================================================
class _PhoneInputView extends StatefulWidget {
  final bool isMobile;

  const _PhoneInputView({required this.isMobile});

  @override
  State<_PhoneInputView> createState() => _PhoneInputViewState();
}

class _PhoneInputViewState extends State<_PhoneInputView> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final phone = _phoneController.text.trim();
    AuthController.instance.sendOtp(phone);
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isMobile ? 20 : 28,
        vertical: widget.isMobile ? 16 : 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.eco_rounded, color: AppColors.primaryGreen, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Farmer Login / Register',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'EBS BioCrop Krishi Portal',
                            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 22),
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Subtitle
          Text(
            'Enter your 10-digit mobile number',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'We will send a one-time OTP verification code to verify your phone number without any password.',
            style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),

          // Phone Number Input with +91 Country Code
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: auth.errorMessage != null ? AppColors.primaryCrimson : const Color(0xFFCBD5E1),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                // Country Code Prefix
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: Color(0xFFCBD5E1))),
                  ),
                  child: Row(
                    children: [
                      Text('🇮🇳', style: GoogleFonts.poppins(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        '+91',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Text Field
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSubmitted: (_) => _submit(),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter Mobile Number',
                      counterText: '',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                        color: AppColors.textMuted,
                        letterSpacing: 0,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      suffixIcon: _phoneController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textMuted),
                              onPressed: () {
                                _phoneController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) {
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),

          // Error Message
          if (auth.errorMessage != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.primaryCrimson),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    auth.errorMessage!,
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.primaryCrimson, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // Quick Demo Pill
          InkWell(
            onTap: () {
              _phoneController.text = '9876543210';
              setState(() {});
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app_rounded, size: 14, color: AppColors.primaryGreen),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Quick Test: Tap to fill demo number (9876543210)',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.primaryDarkGreen, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Get OTP Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: auth.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: auth.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Get OTP via SMS',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
            ),
          ),

          const SizedBox(height: 14),

          // Trust & Security Notes
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user_rounded, size: 14, color: AppColors.primaryGreen),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    '100% Secure • Authenticated Directly via OTP',
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STEP 2: OTP VERIFICATION VIEW
// ============================================================================
class _OtpVerificationView extends StatefulWidget {
  final bool isMobile;

  const _OtpVerificationView({required this.isMobile});

  @override
  State<_OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<_OtpVerificationView> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes[0].requestFocus();
    });
  }

  void _startTimer() {
    _secondsRemaining = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _verify() async {
    final otp = _otp;
    final success = await AuthController.instance.verifyOtp(otp);
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ Login Successful! Welcome to EBS BioCrop.',
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.primaryDarkGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _fillDemoOtp() {
    const demo = '1234';
    for (int i = 0; i < 4; i++) {
      _controllers[i].text = demo[i];
    }
    setState(() {});
    _verify();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;
    final phone = auth.pendingPhone ?? '';

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isMobile ? 20 : 28,
        vertical: widget.isMobile ? 16 : 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Back and Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => AuthController.instance.editPhoneNumber(),
                      icon: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textPrimary),
                      tooltip: 'Change Phone Number',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Verify Mobile OTP',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 22),
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Subtitle with Phone and Edit Action
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Enter 4-digit code sent to ',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                '+91 $phone ',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              InkWell(
                onTap: () => AuthController.instance.editPhoneNumber(),
                child: Text(
                  'Edit',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4-box OTP Input
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return SizedBox(
                width: widget.isMobile ? 54 : 64,
                height: 56,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDarkGreen,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                    ),
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty && index < 3) {
                      _focusNodes[index + 1].requestFocus();
                    } else if (val.isEmpty && index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                    setState(() {});
                    if (_otp.length == 4) {
                      _verify();
                    }
                  },
                ),
              );
            }),
          ),

          // Error Message
          if (auth.errorMessage != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.primaryCrimson),
                const SizedBox(width: 4),
                Text(
                  auth.errorMessage!,
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.primaryCrimson, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Demo OTP Quick Action
          Center(
            child: InkWell(
              onTap: _fillDemoOtp,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flash_on_rounded, size: 14, color: AppColors.primaryGreen),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Test Mode: Tap to auto-verify with demo OTP (1234)',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.primaryDarkGreen,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Verify Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: auth.isLoading || _otp.length < 4 ? null : _verify,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: auth.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Verify & Sign In',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
            ),
          ),

          const SizedBox(height: 14),

          // Resend Timer Row
          Center(
            child: _secondsRemaining > 0
                ? Text(
                    'Resend code in ${_secondsRemaining}s',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                  )
                : TextButton.icon(
                    onPressed: () {
                      _startTimer();
                      auth.resendOtp();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.primaryGreen),
                    label: Text(
                      'Resend OTP via SMS',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STEP 3: LOGGED-IN ACCOUNT PROFILE VIEW
// ============================================================================
class _AccountProfileView extends StatelessWidget {
  final bool isMobile;

  const _AccountProfileView({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;
    final user = auth.currentUser;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 18 : 24,
        vertical: isMobile ? 16 : 22,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Avatar & Details
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user?.name?.isNotEmpty == true
                                ? user!.name!
                                : (user?.formattedPhone ?? 'Farmer Account'),
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'VERIFIED',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDarkGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      user?.formattedPhone ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      user?.location ?? '',
                      style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 22),
                tooltip: 'Close',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 12),

          // Menu Options
          _buildMenuItem(
            icon: Icons.local_shipping_outlined,
            title: 'Track My Orders',
            subtitle: 'Check live dispatch & delivery status',
            onTap: () {
              Navigator.pop(context);
              // Order tracking
            },
          ),
          _buildMenuItem(
            icon: Icons.shopping_bag_outlined,
            title: 'My Cart & Saved Orders',
            subtitle: 'View items and scheduled re-orders',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Saved Delivery Addresses',
            subtitle: 'Village farm depots and delivery points',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _buildMenuItem(
            icon: Icons.support_agent_rounded,
            title: 'Krishi Agronomist Helpline',
            subtitle: 'Toll-free crop advisory support',
            onTap: () {
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 14),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                auth.logout();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'You have been logged out.',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    backgroundColor: AppColors.textPrimary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.primaryCrimson),
              label: Text(
                'Sign Out / Logout',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryCrimson,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFECDD3)),
                backgroundColor: const Color(0xFFFFF1F2),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: AppColors.primaryGreen),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
