import '../../../domain/entities/order_entity.dart';

class ShippingAddressDto {
  final String name;
  final String phoneNumber;
  final String villageArea;
  final String cityTehsil;
  final String state;
  final String pincode;

  ShippingAddressDto({
    required this.name,
    required this.phoneNumber,
    required this.villageArea,
    required this.cityTehsil,
    required this.state,
    required this.pincode,
  });

  factory ShippingAddressDto.fromJson(Map<String, dynamic> json) {
    return ShippingAddressDto(
      name: json['name']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      villageArea: json['villageArea']?.toString() ?? '',
      cityTehsil: json['cityTehsil']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
    );
  }

  ShippingAddressEntity toEntity() => ShippingAddressEntity(
        name: name,
        phoneNumber: phoneNumber,
        villageArea: villageArea,
        cityTehsil: cityTehsil,
        state: state,
        pincode: pincode,
      );
}

class OrderItemDto {
  final String productId;
  final String variantId;
  final String productTitle;
  final String variantLabel;
  final String? imageUrl;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItemDto({
    required this.productId,
    required this.variantId,
    required this.productTitle,
    required this.variantLabel,
    this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) {
    return OrderItemDto(
      productId: json['productId']?.toString() ?? '',
      variantId: json['variantId']?.toString() ?? '',
      productTitle: json['productTitle']?.toString() ?? 'Product',
      variantLabel: json['variantLabel']?.toString() ?? 'Standard Pack',
      imageUrl: json['imageUrl']?.toString(),
      quantity: (json['quantity'] is num) ? (json['quantity'] as num).toInt() : 1,
      unitPrice: (json['unitPrice'] is num) ? (json['unitPrice'] as num).toDouble() : 0.0,
      totalPrice: (json['totalPrice'] is num) ? (json['totalPrice'] as num).toDouble() : 0.0,
    );
  }

  OrderItemEntity toEntity() => OrderItemEntity(
        productId: productId,
        variantId: variantId,
        productTitle: productTitle,
        variantLabel: variantLabel,
        imageUrl: imageUrl,
        quantity: quantity,
        unitPrice: unitPrice,
        totalPrice: totalPrice,
      );
}

class OrderDto {
  final String id;
  final String? checkoutGroupId;
  final String status;
  final String paymentMethod;
  final double? advancePercentage;
  final double totalAmount;
  final double? advancePaid;
  final double? balanceDue;
  final ShippingAddressDto shippingAddress;
  final List<OrderItemDto> items;
  final DateTime createdAt;
  final String? trackingId;
  final String? courierPartner;

  OrderDto({
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

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final itemsList = (rawItems is List)
        ? rawItems.whereType<Map<String, dynamic>>().map((i) => OrderItemDto.fromJson(i)).toList()
        : <OrderItemDto>[];

    final rawAddress = json['shippingAddress'];
    final address = (rawAddress is Map<String, dynamic>)
        ? ShippingAddressDto.fromJson(rawAddress)
        : ShippingAddressDto(
            name: 'Valued Farmer',
            phoneNumber: '',
            villageArea: '',
            cityTehsil: '',
            state: '',
            pincode: '',
          );

    return OrderDto(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      checkoutGroupId: json['checkoutGroupId']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      paymentMethod: json['paymentMethod']?.toString() ?? 'PARTIAL',
      advancePercentage: (json['advancePercentage'] is num)
          ? (json['advancePercentage'] as num).toDouble()
          : null,
      totalAmount: (json['totalAmount'] is num) ? (json['totalAmount'] as num).toDouble() : 0.0,
      advancePaid: (json['advancePaid'] is num) ? (json['advancePaid'] as num).toDouble() : null,
      balanceDue: (json['balanceDue'] is num) ? (json['balanceDue'] as num).toDouble() : null,
      shippingAddress: address,
      items: itemsList,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      trackingId: json['trackingId']?.toString(),
      courierPartner: json['courierPartner']?.toString(),
    );
  }

  OrderEntity toEntity() => OrderEntity(
        id: id,
        checkoutGroupId: checkoutGroupId,
        status: status,
        paymentMethod: paymentMethod,
        advancePercentage: advancePercentage,
        totalAmount: totalAmount,
        advancePaid: advancePaid,
        balanceDue: balanceDue,
        shippingAddress: shippingAddress.toEntity(),
        items: items.map((i) => i.toEntity()).toList(),
        createdAt: createdAt,
        trackingId: trackingId,
        courierPartner: courierPartner,
      );
}
