import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/auth_state.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/main_nav_header.dart';
import '../widgets/top_info_bar.dart';
import '../widgets/web_footer.dart';

class FarmerProfileView extends StatefulWidget {
  const FarmerProfileView({super.key});

  @override
  State<FarmerProfileView> createState() => _FarmerProfileViewState();
}

class _FarmerProfileViewState extends State<FarmerProfileView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _altPhoneController;
  late TextEditingController _emailController;
  late TextEditingController _address1Controller;
  late TextEditingController _villageController;
  late TextEditingController _talukaController;
  late TextEditingController _districtController;
  late TextEditingController _pinCodeController;

  late String _selectedState;
  late String _selectedAddressType;
  late String _selectedFarmerType;
  late String _selectedLandholding;
  final Set<String> _selectedCrops = {};
  bool _isSaving = false;

  static const List<String> _indianStates = [
    'Haryana',
    'Punjab',
    'Uttar Pradesh',
    'Rajasthan',
    'Madhya Pradesh',
    'Gujarat',
    'Maharashtra',
    'Karnataka',
    'Andhra Pradesh',
    'Telangana',
    'Bihar',
    'West Bengal',
    'Tamil Nadu',
    'Odisha',
    'Chhattisgarh',
    'Jharkhand',
    'Uttarakhand',
    'Himachal Pradesh',
    'Assam',
    'Kerala',
  ];

  static const List<String> _farmerTypeOptions = [
    'Individual Farmer',
    'Commercial Farm Owner',
    'Agri Retailer / Dealer',
    'Agronomist / Consultant',
    'FPO / Cooperative Member',
  ];

  static const List<String> _landholdingOptions = [
    '< 2 Acres (Small Holder)',
    '2 - 5 Acres (Medium Holder)',
    '5 - 10 Acres (Commercial)',
    '10 - 25 Acres (Large Scale)',
    '25+ Acres (Enterprise Farm)',
  ];

  static const List<String> _commonCrops = [
    'Wheat',
    'Paddy / Rice',
    'Cotton',
    'Sugarcane',
    'Mustard',
    'Soybean',
    'Potato & Onion',
    'Chilli & Vegetables',
    'Maize / Corn',
    'Fruits & Orchards',
  ];

  @override
  void initState() {
    super.initState();
    final user = AuthController.instance.currentUser;

    _nameController = TextEditingController(text: user?.name ?? '');
    _altPhoneController = TextEditingController(text: user?.alternatePhone ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _address1Controller = TextEditingController(text: user?.addressLine1 ?? '');
    _villageController = TextEditingController(text: user?.villageOrTown ?? '');
    _talukaController = TextEditingController(text: user?.talukaOrTehsil ?? '');
    _districtController = TextEditingController(text: user?.district ?? 'Karnal');
    _pinCodeController = TextEditingController(text: user?.pinCode ?? '132001');

    _selectedState = (user?.state != null && _indianStates.contains(user!.state))
        ? user.state!
        : 'Haryana';
    _selectedAddressType = user?.addressType ?? 'Farm Depot';

    final savedFarmerType = user?.farmerType;
    _selectedFarmerType = (savedFarmerType != null && _farmerTypeOptions.contains(savedFarmerType))
        ? savedFarmerType
        : _farmerTypeOptions[0];

    final savedLand = user?.landholdingAcres;
    _selectedLandholding = (savedLand != null && _landholdingOptions.contains(savedLand))
        ? savedLand
        : _landholdingOptions[2]; // '5 - 10 Acres (Commercial)'

    if (user?.primaryCrops != null && user!.primaryCrops!.isNotEmpty) {
      _selectedCrops.addAll(
        user.primaryCrops!.split(',').map((c) => c.trim()).where((c) => c.isNotEmpty),
      );
    } else {
      _selectedCrops.addAll(['Wheat', 'Paddy / Rice']);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _altPhoneController.dispose();
    _emailController.dispose();
    _address1Controller.dispose();
    _villageController.dispose();
    _talukaController.dispose();
    _districtController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required address fields correctly.'),
          backgroundColor: AppColors.primaryCrimson,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 400));

    AuthController.instance.updateProfile(
      name: _nameController.text.trim(),
      alternatePhone: _altPhoneController.text.trim(),
      email: _emailController.text.trim(),
      addressLine1: _address1Controller.text.trim(),
      villageOrTown: _villageController.text.trim(),
      talukaOrTehsil: _talukaController.text.trim(),
      district: _districtController.text.trim(),
      state: _selectedState,
      pinCode: _pinCodeController.text.trim(),
      addressType: _selectedAddressType,
      farmerType: _selectedFarmerType,
      primaryCrops: _selectedCrops.join(', '),
      landholdingAcres: _selectedLandholding,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Farmer profile and farm delivery address saved successfully!',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AuthController.instance,
      builder: (context, _) {
        final auth = AuthController.instance;
        final user = auth.currentUser;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.background,
          endDrawer: const QuickCartDrawer(),
          body: Column(
            children: [
              // Sticky Header
              Container(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const TopInfoBar(),
                    MainNavHeader(
                      onCartTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                    ),
                  ],
                ),
              ),

              // Scrollable Profile Page Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 900;

                          return Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 24,
                              vertical: isMobile ? 12 : 24,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1400),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Breadcrumb Bar
                                    _buildBreadcrumb(context),
                                    const SizedBox(height: 14),

                                    // Hero Farmer Account Banner Card
                                    _buildAccountBanner(user, isMobile),
                                    const SizedBox(height: 20),

                                    // Main Two-Column or Single-Column Content
                                    if (isMobile)
                                      Column(
                                        children: [
                                          _buildFormCard(context, isMobile),
                                          const SizedBox(height: 20),
                                          _buildSideInfoCard(user),
                                        ],
                                      )
                                    else
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Main Edit Form (65%)
                                          Expanded(
                                            flex: 65,
                                            child: _buildFormCard(context, isMobile),
                                          ),
                                          const SizedBox(width: 24),
                                          // Side Shipping Preview & Perks (35%)
                                          Expanded(
                                            flex: 35,
                                            child: _buildSideInfoCard(user),
                                          ),
                                        ],
                                      ),

                                    const SizedBox(height: 48),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Footer
                      const WebFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreadcrumb(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.textPrimary),
                  const SizedBox(width: 6),
                  Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('/', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(width: 10),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Text(
              'Home',
              style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Text('/', style: GoogleFonts.poppins(color: AppColors.textMuted, fontSize: 13)),
          const SizedBox(width: 8),
          Text(
            'Farmer Profile & Delivery Address',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountBanner(UserModel? user, bool isMobile) {
    final displayName = (user?.name != null && user!.name!.trim().isNotEmpty)
        ? user.name!.trim()
        : 'Farmer Partner';
    final displayPhone = user?.formattedPhone ?? '+91 98765 43210';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'F';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with initial
          Container(
            width: isMobile ? 54 : 68,
            height: isMobile ? 54 : 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 24 : 30,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDarkGreen,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      displayName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isMobile ? 18 : 22,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'VERIFIED FARMER',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Primary Mobile: $displayPhone • Member Since ${user?.memberSince ?? 'Oct 2026'}',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: isMobile ? 11.5 : 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Farm Depot: ${user?.location ?? 'Punjab & Haryana Agricultural Belt'}',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: isMobile ? 11 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 18 : 28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Farmer Identity
            _buildSectionHeader(
              icon: Icons.person_outline_rounded,
              title: 'Personal & Contact Details',
              subtitle: 'Ensure your name matches your identity for smooth parcel delivery',
            ),
            const SizedBox(height: 18),

            // Full Name Input
            _buildTextField(
              controller: _nameController,
              label: 'Farmer / Customer Full Name *',
              hint: 'e.g. Ramesh Kumar Patel',
              icon: Icons.badge_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone Numbers Row
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 600;
                final phoneField = _buildReadOnlyField(
                  label: 'Registered Mobile Number (Verified via OTP)',
                  value: AuthController.instance.currentUser?.formattedPhone ?? '+91 98765 43210',
                  icon: Icons.phone_android_rounded,
                  badge: 'Verified',
                );

                final altPhoneField = _buildTextField(
                  controller: _altPhoneController,
                  label: 'Alternate Mobile (Optional)',
                  hint: 'e.g. 9876543211 (For farm delivery rider)',
                  icon: Icons.phone_forwarded_outlined,
                  keyboardType: TextInputType.phone,
                );

                if (isNarrow) {
                  return Column(
                    children: [
                      phoneField,
                      const SizedBox(height: 16),
                      altPhoneField,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: phoneField),
                    const SizedBox(width: 16),
                    Expanded(child: altPhoneField),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Email & Role
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 600;
                final emailField = _buildTextField(
                  controller: _emailController,
                  label: 'Email Address (Optional)',
                  hint: 'e.g. ramesh.patel@gmail.com (For invoice & GST)',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                );

                final farmerTypeField = _buildDropdownField<String>(
                  label: 'Farmer / Buyer Category',
                  value: _selectedFarmerType,
                  items: _farmerTypeOptions,
                  icon: Icons.agriculture_rounded,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedFarmerType = val);
                  },
                );

                if (isNarrow) {
                  return Column(
                    children: [
                      emailField,
                      const SizedBox(height: 16),
                      farmerTypeField,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: emailField),
                    const SizedBox(width: 16),
                    Expanded(child: farmerTypeField),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),
            const Divider(color: Color(0xFFE2E8F0), height: 1),
            const SizedBox(height: 28),

            // Section 2: Farm & Delivery Address
            _buildSectionHeader(
              icon: Icons.location_on_outlined,
              title: 'Farm Depot & Delivery Address',
              subtitle: 'EBS logistics delivers certified fertilizers & protection right to your farm',
            ),
            const SizedBox(height: 18),

            // Address Line 1
            _buildTextField(
              controller: _address1Controller,
              label: 'House / Plot / Khasra No. & Street / Farm Depot Landmark *',
              hint: 'e.g. Farm Depot 14, Near Village Canal Gate, Grand Trunk Road',
              icon: Icons.home_work_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter street, farm depot or landmark address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Village & Taluka Row
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 600;
                final villageField = _buildTextField(
                  controller: _villageController,
                  label: 'Village / Gram Panchayat / Town *',
                  hint: 'e.g. Nilokheri / Taraori',
                  icon: Icons.holiday_village_outlined,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your village or town name';
                    }
                    return null;
                  },
                );

                final talukaField = _buildTextField(
                  controller: _talukaController,
                  label: 'Tehsil / Taluka / Block *',
                  hint: 'e.g. Karnal Tehsil',
                  icon: Icons.account_balance_outlined,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your tehsil or taluka';
                    }
                    return null;
                  },
                );

                if (isNarrow) {
                  return Column(
                    children: [
                      villageField,
                      const SizedBox(height: 16),
                      talukaField,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: villageField),
                    const SizedBox(width: 16),
                    Expanded(child: talukaField),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // District, State & Pincode Row
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 650;
                final districtField = _buildTextField(
                  controller: _districtController,
                  label: 'District *',
                  hint: 'e.g. Karnal',
                  icon: Icons.map_outlined,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter district';
                    }
                    return null;
                  },
                );

                final stateField = _buildDropdownField<String>(
                  label: 'State *',
                  value: _selectedState,
                  items: _indianStates,
                  icon: Icons.location_city_outlined,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedState = val);
                  },
                );

                final pinCodeField = _buildTextField(
                  controller: _pinCodeController,
                  label: 'PIN Code *',
                  hint: 'e.g. 132001',
                  icon: Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().length != 6 || int.tryParse(v.trim()) == null) {
                      return 'Enter 6-digit PIN';
                    }
                    return null;
                  },
                );

                if (isNarrow) {
                  return Column(
                    children: [
                      districtField,
                      const SizedBox(height: 16),
                      stateField,
                      const SizedBox(height: 16),
                      pinCodeField,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(flex: 35, child: districtField),
                    const SizedBox(width: 14),
                    Expanded(flex: 38, child: stateField),
                    const SizedBox(width: 14),
                    Expanded(flex: 27, child: pinCodeField),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Address Type selector
            Text(
              'Delivery Address Tag:',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _buildAddressTypeChip('🌾 Farm Depot / Khet'),
                _buildAddressTypeChip('🏡 Village Residence'),
                _buildAddressTypeChip('🏪 Agri Shop / Godown'),
              ],
            ),

            const SizedBox(height: 32),
            const Divider(color: Color(0xFFE2E8F0), height: 1),
            const SizedBox(height: 28),

            // Section 3: Agricultural Crop Details
            _buildSectionHeader(
              icon: Icons.eco_outlined,
              title: 'Farm Land & Crop Cultivation (Optional)',
              subtitle: 'Allows EBS scientific agronomists to recommend the ideal dosage for your soil',
            ),
            const SizedBox(height: 18),

            // Landholding
            _buildDropdownField<String>(
              label: 'Total Farm Landholding (in Acres)',
              value: _selectedLandholding,
              items: _landholdingOptions,
              icon: Icons.landscape_outlined,
              onChanged: (val) {
                if (val != null) setState(() => _selectedLandholding = val);
              },
            ),
            const SizedBox(height: 16),

            Text(
              'Major Crops Sown this Season:',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonCrops.map((crop) {
                final isSelected = _selectedCrops.contains(crop);
                return FilterChip(
                  label: Text(crop),
                  selected: isSelected,
                  selectedColor: AppColors.lightGreen,
                  checkmarkColor: AppColors.primaryDarkGreen,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryGreen : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.4 : 1,
                  ),
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.primaryDarkGreen : AppColors.textPrimary,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCrops.add(crop);
                      } else {
                        _selectedCrops.remove(crop);
                      }
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 36),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveProfile,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle_outline_rounded, size: 20),
                    label: Text(
                      _isSaving ? 'Saving Profile...' : 'Save Profile & Delivery Address',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryDarkGreen, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMuted),
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    required String badge,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryDarkGreen),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check, size: 12, color: AppColors.primaryDarkGreen),
                    const SizedBox(width: 3),
                    Text(
                      badge,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDarkGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required IconData icon,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                item.toString(),
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 13.5, color: AppColors.textPrimary),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.textSecondary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressTypeChip(String label) {
    final isSelected = _selectedAddressType == label;
    return InkWell(
      onTap: () => setState(() => _selectedAddressType = label),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : const Color(0xFFCBD5E1),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSideInfoCard(UserModel? user) {
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : (user?.name ?? 'Farmer Name');
    final phone = user?.formattedPhone ?? '+91 98765 43210';
    final altPhone = _altPhoneController.text.trim().isNotEmpty
        ? 'Alt: +91 ${_altPhoneController.text.trim()}'
        : '';
    final addressLine = _address1Controller.text.trim().isNotEmpty
        ? _address1Controller.text.trim()
        : 'Farm Depot / Plot Address';
    final village = _villageController.text.trim().isNotEmpty ? 'Vill: ${_villageController.text.trim()}' : '';
    final taluka = _talukaController.text.trim().isNotEmpty ? 'Teh: ${_talukaController.text.trim()}' : '';
    final district = _districtController.text.trim().isNotEmpty ? _districtController.text.trim() : 'District';
    final state = _selectedState;
    final pin = _pinCodeController.text.trim().isNotEmpty ? 'PIN - ${_pinCodeController.text.trim()}' : 'PIN';

    return Column(
      children: [
        // Live Shipping Label Preview Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                  border: Border(bottom: BorderSide(color: Color(0xFFDCFCE7))),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping_rounded, color: AppColors.primaryGreen, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Live Parcel Dispatch Preview',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDarkGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'EBS EXPRESS',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Address Body
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Deliver To:',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _selectedAddressType,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$phone ${altPhone.isNotEmpty ? '• $altPhone' : ''}',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDarkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 12),
                    Text(
                      addressLine,
                      style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textPrimary),
                    ),
                    if (village.isNotEmpty || taluka.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        [if (village.isNotEmpty) village, if (taluka.isNotEmpty) taluka].join(', '),
                        style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textPrimary),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      '$district, $state - $pin',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.primaryGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tamper-Proof BioCrop Packaging & Insured Farm Transit',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Agronomist Support Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.support_agent_rounded, color: Color(0xFFD97706), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Krishi Expert Advisory',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Toll-Free Helpline for Farmers',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Need guidance on choosing the right bio-fertilizer formulation for your soil or crop schedule? Our certified agricultural scientists are ready to assist.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Calling Krishi Helpline: 1800-203-1425 (Toll-Free)'),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                },
                icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                label: const Text('Call: 1800-203-1425'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryDarkGreen,
                  side: const BorderSide(color: AppColors.primaryGreen),
                  minimumSize: const Size(double.infinity, 42),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
