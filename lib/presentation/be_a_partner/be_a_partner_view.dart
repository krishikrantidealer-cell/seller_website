import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/top_info_bar.dart';
import '../widgets/main_nav_header.dart';
import '../widgets/category_ribbon.dart';
import '../widgets/web_footer.dart';

class BeAPartnerView extends StatefulWidget {
  const BeAPartnerView({super.key});

  @override
  State<BeAPartnerView> createState() => _BeAPartnerViewState();
}

class _BeAPartnerViewState extends State<BeAPartnerView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController(text: 'India');
  final _companyNameController = TextEditingController();
  final _webAddressController = TextEditingController();
  final _activitiesController = TextEditingController();

  bool _isSubmitting = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _companyNameController.dispose();
    _webAddressController.dispose();
    _activitiesController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const TopInfoBar(),
          const MainNavHeader(),
          const CategoryRibbon(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildBreadcrumb(context, isMobile),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 32,
                      vertical: isMobile ? 24 : 40,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 880),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(isMobile ? 20 : 36),
                          child: _isSubmitted
                              ? _buildSuccessView(isMobile)
                              : _buildFormView(isMobile),
                        ),
                      ),
                    ),
                  ),
                  const WebFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.primaryGreen),
                const SizedBox(width: 6),
                Text(
                  'Home',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text('/', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(width: 8),
          Text(
            'Be a Partner',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView(bool isMobile) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Be a Partner',
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 22 : 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Partner Welcome Letter
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dear Partner,',
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF166534),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Have a bright future ahead!!!',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF15803D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Thanks for visiting India's fast growing e-commerce website/application.",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF166534),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'If you are interested to be a part of Agribegri Tradelink Private Limited then fill up following detail.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF166534),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Our top management and commerce department will contact you.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF15803D),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Thanks again.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF166534),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Team Agribegri.',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF166534),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Name
          _buildFieldLabel('Name', isRequired: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            decoration: _inputDecoration('Enter your Name', Icons.person_outline_rounded),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter your name';
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Phone & Email Row
          if (isMobile) ...[
            _buildFieldLabel('Phone Number', isRequired: true),
            const SizedBox(height: 6),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('Enter your Phone Number', Icons.phone_outlined),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Please enter your phone number';
                final cleaned = val.replaceAll(RegExp(r'\D'), '');
                if (cleaned.length < 10) return 'Please enter a valid 10-digit phone number';
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildFieldLabel('Email', isRequired: true),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration('Enter your Email Address', Icons.email_outlined),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Please enter your email address';
                if (!val.contains('@') || !val.contains('.')) return 'Please enter a valid email address';
                return null;
              },
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Phone Number', isRequired: true),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration('Enter your Phone Number', Icons.phone_outlined),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter your phone number';
                          final cleaned = val.replaceAll(RegExp(r'\D'), '');
                          if (cleaned.length < 10) return 'Please enter a valid 10-digit phone number';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Email', isRequired: true),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration('Enter your Email Address', Icons.email_outlined),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter your email address';
                          if (!val.contains('@') || !val.contains('.')) return 'Please enter a valid email address';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),

          // City & Country Row
          if (isMobile) ...[
            _buildFieldLabel('City', isRequired: true),
            const SizedBox(height: 6),
            TextFormField(
              controller: _cityController,
              decoration: _inputDecoration('Enter your city name', Icons.location_city_rounded),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Please enter your city';
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildFieldLabel('Country', isRequired: true),
            const SizedBox(height: 6),
            TextFormField(
              controller: _countryController,
              readOnly: true,
              decoration: _inputDecoration('India', Icons.public_rounded),
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('City', isRequired: true),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _cityController,
                        decoration: _inputDecoration('Enter your city name', Icons.location_city_rounded),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter your city';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Country', isRequired: true),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _countryController,
                        readOnly: true,
                        decoration: _inputDecoration('India', Icons.public_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),

          // Company Name & Web Address
          if (isMobile) ...[
            _buildFieldLabel('Company Name', isRequired: true),
            const SizedBox(height: 6),
            TextFormField(
              controller: _companyNameController,
              decoration: _inputDecoration('Enter your Company Name', Icons.business_rounded),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Please enter your company name';
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildFieldLabel('Web Address', isRequired: false),
            const SizedBox(height: 6),
            TextFormField(
              controller: _webAddressController,
              keyboardType: TextInputType.url,
              decoration: _inputDecoration('Enter your Web Address', Icons.language_rounded),
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Company Name', isRequired: true),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _companyNameController,
                        decoration: _inputDecoration('Enter your Company Name', Icons.business_rounded),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter your company name';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFieldLabel('Web Address', isRequired: false),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _webAddressController,
                        keyboardType: TextInputType.url,
                        decoration: _inputDecoration('Enter your Web Address', Icons.language_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),

          // Company Activities
          _buildFieldLabel('Company Activities', isRequired: true),
          const SizedBox(height: 6),
          TextFormField(
            controller: _activitiesController,
            maxLines: 4,
            decoration: _inputDecoration('Enter your Company Activities', Icons.assignment_outlined),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please describe your company activities';
              return null;
            },
          ),
          const SizedBox(height: 28),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(
                      'SUBMIT',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, size: 48, color: Color(0xFF16A34A)),
          ),
          const SizedBox(height: 20),
          Text(
            'Partner Application Submitted!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Thank you for your interest in partnering with us.\nOur top management and commerce department will review your details and contact you shortly.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Back to Home'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              side: const BorderSide(color: AppColors.primaryGreen),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, {required bool isRequired}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(color: AppColors.primaryCrimson, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted),
      prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryCrimson),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryCrimson, width: 1.8),
      ),
    );
  }
}
