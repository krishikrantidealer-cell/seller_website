import 'package:equatable/equatable.dart';
import 'product_entity.dart';

class WishlistEntity extends Equatable {
  final List<String> variantIds;
  final List<ProductEntity> products;

  const WishlistEntity({
    this.variantIds = const [],
    this.products = const [],
  });

  bool containsProduct(String productId) =>
      products.any((p) => p.id == productId);

  bool containsVariant(String variantId) =>
      variantIds.contains(variantId);

  int get totalCount => products.length;
  bool get isEmpty => products.isEmpty;

  @override
  List<Object?> get props => [variantIds, products];
}
