import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';

abstract class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => [];
}

class LoadCatalog extends CatalogEvent {
  const LoadCatalog();
}

class SelectCategory extends CatalogEvent {
  final String categoryId;
  const SelectCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class SearchTechnicalOrBrand extends CatalogEvent {
  final String query;
  const SearchTechnicalOrBrand(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectProductVariant extends CatalogEvent {
  final String productId;
  final PackVariant variant;

  const SelectProductVariant({required this.productId, required this.variant});

  @override
  List<Object?> get props => [productId, variant];
}
