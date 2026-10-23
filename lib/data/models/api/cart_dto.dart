import '../../../domain/entities/cart_entity.dart';

class CartItemDto {
  final String id;
  final String productId;
  final String variantId;
  final int quantity;
  final double price;

  CartItemDto({
    required this.id,
    required this.productId,
    required this.variantId,
    required this.quantity,
    required this.price,
  });

  factory CartItemDto.fromJson(Map<String, dynamic> json) {
    return CartItemDto(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      variantId: json['variantId']?.toString() ?? '',
      quantity: (json['quantity'] is num) ? (json['quantity'] as num).toInt() : 1,
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
    );
  }

  CartItemEntity toEntity() => CartItemEntity(
        id: id,
        productId: productId,
        variantId: variantId,
        quantity: quantity,
        price: price,
      );
}

class CartDto {
  final String? id;
  final List<CartItemDto> items;
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;

  CartDto({
    this.id,
    this.items = const [],
    this.totalAmount = 0.0,
    this.discountAmount = 0.0,
    this.finalAmount = 0.0,
  });

  factory CartDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final itemsList = (rawItems is List)
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map((item) => CartItemDto.fromJson(item))
            .toList()
        : <CartItemDto>[];

    return CartDto(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      items: itemsList,
      totalAmount: (json['totalAmount'] is num) ? (json['totalAmount'] as num).toDouble() : 0.0,
      discountAmount: (json['discountAmount'] is num) ? (json['discountAmount'] as num).toDouble() : 0.0,
      finalAmount: (json['finalAmount'] is num) ? (json['finalAmount'] as num).toDouble() : 0.0,
    );
  }

  CartEntity toEntity() => CartEntity(
        id: id,
        items: items.map((i) => i.toEntity()).toList(),
        totalAmount: totalAmount,
        discountAmount: discountAmount,
        finalAmount: finalAmount,
      );
}
