import 'package:flutter/foundation.dart';

/// User representation for authenticated farmers/customers
class UserModel {
  final String phoneNumber;
  final String name;
  final String? email;
  final String location;
  final String memberSince;

  const UserModel({
    required this.phoneNumber,
    this.name = 'Kisan Mitra',
    this.email,
    this.location = 'Karnal, Haryana',
    this.memberSince = 'Oct 2026',
  });

  String get formattedPhone {
    if (phoneNumber.length == 10) {
      return '+91 ${phoneNumber.substring(0, 5)} ${phoneNumber.substring(5)}';
    }
    return '+91 $phoneNumber';
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
      name: 'Kisan Farmer',
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

  /// Log out
  void logout() {
    _currentUser = null;
    _pendingPhone = null;
    _errorMessage = null;
    notifyListeners();
  }
}
