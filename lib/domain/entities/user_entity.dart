import 'package:equatable/equatable.dart';

class UserAddressEntity extends Equatable {
  final String? villageArea;
  final String? cityTehsil;
  final String? state;
  final String? pincode;
  final String? address2;

  const UserAddressEntity({
    this.villageArea,
    this.cityTehsil,
    this.state,
    this.pincode,
    this.address2,
  });

  String get formattedAddress {
    final parts = [
      villageArea,
      address2,
      cityTehsil,
      state,
      pincode,
    ].where((p) => p != null && p.trim().isNotEmpty).toList();
    return parts.isEmpty ? 'No address specified' : parts.join(', ');
  }

  @override
  List<Object?> get props => [villageArea, cityTehsil, state, pincode, address2];
}

class UserEntity extends Equatable {
  final String id;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? role;
  final UserAddressEntity? address;
  final String? primaryCrops;
  final String? landholdingAcres;

  const UserEntity({
    required this.id,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.email,
    this.role = 'ROLE_CUSTOMER',
    this.address,
    this.primaryCrops,
    this.landholdingAcres,
  });

  String get fullName {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';
    if (first.isEmpty && last.isEmpty) {
      return formattedPhone;
    }
    return '$first $last'.trim();
  }

  String get formattedPhone {
    if (phoneNumber.length == 10) {
      return '+91 ${phoneNumber.substring(0, 5)} ${phoneNumber.substring(5)}';
    }
    return phoneNumber.startsWith('+91') ? phoneNumber : '+91 $phoneNumber';
  }

  @override
  List<Object?> get props => [
        id,
        phoneNumber,
        firstName,
        lastName,
        email,
        role,
        address,
        primaryCrops,
        landholdingAcres,
      ];
}
