import '../../../domain/entities/user_entity.dart';

class UserAddressDto {
  final String? villageArea;
  final String? cityTehsil;
  final String? state;
  final String? pincode;
  final String? address2;

  UserAddressDto({
    this.villageArea,
    this.cityTehsil,
    this.state,
    this.pincode,
    this.address2,
  });

  factory UserAddressDto.fromJson(Map<String, dynamic> json) {
    return UserAddressDto(
      villageArea: json['villageArea']?.toString(),
      cityTehsil: json['cityTehsil']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
      address2: json['address2']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (villageArea != null) 'villageArea': villageArea,
        if (cityTehsil != null) 'cityTehsil': cityTehsil,
        if (state != null) 'state': state,
        if (pincode != null) 'pincode': pincode,
        if (address2 != null) 'address2': address2,
      };

  UserAddressEntity toEntity() => UserAddressEntity(
        villageArea: villageArea,
        cityTehsil: cityTehsil,
        state: state,
        pincode: pincode,
        address2: address2,
      );
}

class UserDto {
  final String id;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? role;
  final UserAddressDto? address;

  UserDto({
    required this.id,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.email,
    this.role,
    this.address,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString(),
      address: json['address'] is Map<String, dynamic>
          ? UserAddressDto.fromJson(json['address'])
          : null,
    );
  }

  UserEntity toEntity() => UserEntity(
        id: id,
        phoneNumber: phoneNumber,
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role ?? 'ROLE_CUSTOMER',
        address: address?.toEntity(),
      );
}
