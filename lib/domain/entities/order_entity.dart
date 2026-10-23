import 'package:equatable/equatable.dart';

class ShippingAddressEntity extends Equatable {
  final String name;
  final String phoneNumber;
  final String villageArea;
  final String cityTehsil;
  final String state;
  final String pincode;

  const ShippingAddressEntity({
    required this.name,
    required this.phoneNumber,
    required this.villageArea,
    required this.cityTehsil,
    required this.state,
    required this.pincode,
  });

  String get formatted => '$villageArea, $cityTehsil, $state - $pincode';

  Map<String, dynamic> toJson() => {
        'name': name,
        'phoneNumber': phoneNumber,
        'villageArea': villageArea,
        'cityTehsil': cityTehsil,
        'state': state,
        'pincode': pincode,
      };

  @override
  List<Object?> get props => [name, phoneNumber, villageArea, cityTehsil, state, pincode];
}

class OrderItemEntity extends Equatable {
  final String productId;
  final String variantId;
  final String productTitle;
  final String variantLabel;
  final String? imageUrl;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const OrderItemEntity({
    required this.productId,
    required this.variantId,
    required this.productTitle,
    required this.variantLabel,
    this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [
        productId,
        variantId,
        productTitle,
        variantLabel,
        imageUrl,
        quantity,
        unitPrice,
        totalPrice,
      ];
}

class OrderEntity extends Equatable {
  final String id;
  final String? checkoutGroupId;
  final String status;
  final String paymentMethod;
  final double? advancePercentage;
  final double totalAmount;
  final double? advancePaid;
  final double? balanceDue;
  final ShippingAddressEntity shippingAddress;
  final List<OrderItemEntity> items;
  final DateTime createdAt;
  final String? trackingId;
  final String? courierPartner;

  const OrderEntity({
    required this.id,
    this.checkoutGroupId,
    required this.status,
    required this.paymentMethod,
    this.advancePercentage,
    required this.totalAmount,
    this.advancePaid,
    this.balanceDue,
    required this.shippingAddress,
    this.items = const [],
    required this.createdAt,
    this.trackingId,
    this.courierPartner,
  });

  @override
  List<Object?> get props => [
        id,
        checkoutGroupId,
        status,
        paymentMethod,
        advancePercentage,
        totalAmount,
        advancePaid,
        balanceDue,
        shippingAddress,
        items,
        createdAt,
        trackingId,
        courierPartner,
      ];
}
