import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class SendOtpEvent extends AuthEvent {
  final String phoneNumber;

  const SendOtpEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyOtpEvent extends AuthEvent {
  final String phoneNumber;
  final String otp;

  const VerifyOtpEvent({required this.phoneNumber, required this.otp});

  @override
  List<Object?> get props => [phoneNumber, otp];
}

class UpdateProfileEvent extends AuthEvent {
  final String? firstName;
  final String? lastName;
  final UserAddressEntity? address;

  const UpdateProfileEvent({this.firstName, this.lastName, this.address});

  @override
  List<Object?> get props => [firstName, lastName, address];
}

class LogoutEvent extends AuthEvent {}
