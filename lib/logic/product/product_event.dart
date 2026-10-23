import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class FetchProductsEvent extends ProductEvent {
  final int page;
  final int size;

  const FetchProductsEvent({this.page = 0, this.size = 20});

  @override
  List<Object?> get props => [page, size];
}

class FetchProductDetailEvent extends ProductEvent {
  final String productId;

  const FetchProductDetailEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class FilterByCategoryEvent extends ProductEvent {
  final String categoryId;
  final String? subcategory;

  const FilterByCategoryEvent({required this.categoryId, this.subcategory});

  @override
  List<Object?> get props => [categoryId, subcategory];
}

class SearchProductsEvent extends ProductEvent {
  final String query;

  const SearchProductsEvent(this.query);

  @override
  List<Object?> get props => [query];
}
