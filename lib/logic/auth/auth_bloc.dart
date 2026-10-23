import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final profile = await _authRepository.getProfile();
        if (profile != null) {
          emit(AuthenticatedState(profile));
          return;
        }
      }
      emit(UnauthenticatedState());
    } catch (_) {
      emit(UnauthenticatedState());
    }
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final success = await _authRepository.sendOtp(event.phoneNumber);
      if (success) {
        emit(OtpSentState(phoneNumber: event.phoneNumber));
      } else {
        emit(const AuthErrorState('Failed to send OTP. Please try again.'));
      }
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.verifyOtp(
        phoneNumber: event.phoneNumber,
        otp: event.otp,
      );
      emit(AuthenticatedState(user));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.updateProfile(
        firstName: event.firstName,
        lastName: event.lastName,
        address: event.address,
      );
      emit(AuthenticatedState(user));
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
    } catch (_) {}
    emit(UnauthenticatedState());
  }
}
