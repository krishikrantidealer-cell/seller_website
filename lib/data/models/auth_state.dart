import 'package:flutter/foundation.dart';

/// User representation for authenticated farmers/customers
class UserModel {
  final String phoneNumber;
  final String? name;
  final String? alternatePhone;
  final String? email;
  final String location;
  final String memberSince;
  final String? addressLine1;
  final String? villageOrTown;
  final String? talukaOrTehsil;
  final String? district;
  final String? state;
  final String? pinCode;
  final String addressType;
  final String farmerType;
  final String? primaryCrops;
  final String? landholdingAcres;

  const UserModel({
    required this.phoneNumber,
    this.name,
    this.alternatePhone,
    this.email,
    this.location = 'Karnal, Haryana',
    this.memberSince = 'Oct 2026',
    this.addressLine1,
    this.villageOrTown,
    this.talukaOrTehsil,
    this.district,
    this.state,
    this.pinCode,
    this.addressType = 'Farm Depot',
    this.farmerType = 'Individual Farmer',
    this.primaryCrops,
    this.landholdingAcres,
  });

  String get formattedPhone {
    if (phoneNumber.length == 10) {
      return '+91 ${phoneNumber.substring(0, 5)} ${phoneNumber.substring(5)}';
    }
    return '+91 $phoneNumber';
  }

  String get fullAddress {
    final parts = [
      if (addressLine1 != null && addressLine1!.trim().isNotEmpty) addressLine1!.trim(),
      if (villageOrTown != null && villageOrTown!.trim().isNotEmpty) 'Vill: ${villageOrTown!.trim()}',
      if (talukaOrTehsil != null && talukaOrTehsil!.trim().isNotEmpty) 'Teh: ${talukaOrTehsil!.trim()}',
      if (district != null && district!.trim().isNotEmpty) district!.trim(),
      if (state != null && state!.trim().isNotEmpty) state!.trim(),
      if (pinCode != null && pinCode!.trim().isNotEmpty) 'PIN - ${pinCode!.trim()}',
    ];
    if (parts.isEmpty) return 'No delivery address saved yet';
    return parts.join(', ');
  }

  UserModel copyWith({
    String? phoneNumber,
    String? name,
    String? alternatePhone,
    String? email,
    String? location,
    String? memberSince,
    String? addressLine1,
    String? villageOrTown,
    String? talukaOrTehsil,
    String? district,
    String? state,
    String? pinCode,
    String? addressType,
    String? farmerType,
    String? primaryCrops,
    String? landholdingAcres,
  }) {
    return UserModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      email: email ?? this.email,
      location: location ?? this.location,
      memberSince: memberSince ?? this.memberSince,
      addressLine1: addressLine1 ?? this.addressLine1,
      villageOrTown: villageOrTown ?? this.villageOrTown,
      talukaOrTehsil: talukaOrTehsil ?? this.talukaOrTehsil,
      district: district ?? this.district,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      addressType: addressType ?? this.addressType,
      farmerType: farmerType ?? this.farmerType,
      primaryCrops: primaryCrops ?? this.primaryCrops,
      landholdingAcres: landholdingAcres ?? this.landholdingAcres,
    );
  }
}

/// Authentication state manager handling phone number + OTP verification
class AuthController extends ChangeNotifier {
  static final AuthController instance = AuthController._internal();
  AuthController._internal();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _pendingPhone;
  String? _errorMessage;

  bool get isLoggedIn => _currentUser != null;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get pendingPhone => _pendingPhone;
  String? get errorMessage => _errorMessage;

  /// Initiate Phone OTP login
  Future<bool> sendOtp(String rawPhone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Small delay to simulate network call
    await Future.delayed(const Duration(milliseconds: 400));

    final digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      _errorMessage = 'Please enter a valid 10-digit mobile number';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _pendingPhone = digits;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Verify OTP (accepts demo OTP '1234' or any valid 4-digit code for testing)
  Future<bool> verifyOtp(String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 450));

    final cleanOtp = otp.trim();
    if (cleanOtp.length != 4 && cleanOtp.length != 6) {
      _errorMessage = 'Please enter the 4-digit verification code';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    final phone = _pendingPhone ?? '9876543210';
    _currentUser = UserModel(
      phoneNumber: phone,
      location: 'Punjab & Haryana Agricultural Belt',
    );
    _pendingPhone = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  /// Resend OTP
  Future<bool> resendOtp() async {
    if (_pendingPhone == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Reset pending state (e.g. to change phone number)
  void editPhoneNumber() {
    _pendingPhone = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Update Profile information (Name, Farm Address, Crop Details, etc.)
  void updateProfile({
    String? name,
    String? alternatePhone,
    String? email,
    String? addressLine1,
    String? villageOrTown,
    String? talukaOrTehsil,
    String? district,
    String? state,
    String? pinCode,
    String? addressType,
    String? farmerType,
    String? primaryCrops,
    String? landholdingAcres,
  }) {
    final current = _currentUser ?? const UserModel(phoneNumber: '9876543210');
    _currentUser = current.copyWith(
      name: name,
      alternatePhone: alternatePhone,
      email: email,
      addressLine1: addressLine1,
      villageOrTown: villageOrTown,
      talukaOrTehsil: talukaOrTehsil,
      district: district,
      state: state,
      pinCode: pinCode,
      addressType: addressType,
      farmerType: farmerType,
      primaryCrops: primaryCrops,
      landholdingAcres: landholdingAcres,
      location: (district != null && state != null && district.isNotEmpty && state.isNotEmpty)
          ? '$district, $state'
          : current.location,
    );
    notifyListeners();
  }

  /// For testing: set user directly
  void setUserForTest(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Log out
  void logout() {
    _currentUser = null;
    _pendingPhone = null;
    _errorMessage = null;
    notifyListeners();
  }
}
