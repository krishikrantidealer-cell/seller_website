import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductsLoadedState extends ProductState {
  final List<ProductEntity> products;
  final String? activeCategory;
  final String? activeSubcategory;
  final String? searchQuery;

  const ProductsLoadedState({
    required this.products,
    this.activeCategory,
    this.activeSubcategory,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [products, activeCategory, activeSubcategory, searchQuery];
}

class ProductDetailLoadedState extends ProductState {
  final ProductEntity product;

  const ProductDetailLoadedState(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductErrorState extends ProductState {
  final String message;

  const ProductErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
