import 'package:equatable/equatable.dart';
import '../../data/models/catalog_models.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

/// Instant 0ms cache hydration followed by background API synchronization
class InitializeCategories extends CategoryEvent {
  const InitializeCategories();
}

/// Fetches categories from `GET /api/v1/categories`
class FetchCategories extends CategoryEvent {
  final bool isRefresh;
  final bool isBackground;

  const FetchCategories({
    this.isRefresh = false,
    this.isBackground = false,
  });

  @override
  List<Object?> get props => [isRefresh, isBackground];
}

/// Triggered when `CategoryController` or a real-time WebSocket update supplies a new hierarchy
class CategoriesExternalUpdated extends CategoryEvent {
  final List<CategoryItem> categories;

  const CategoriesExternalUpdated(this.categories);

  @override
  List<Object?> get props => [categories];
}

/// Selects a Level 0 Major Category and/or Level 1/Level 2 Subcategory
class SelectCategoryFilter extends CategoryEvent {
  final String categoryId;
  final String? subcategory;

  const SelectCategoryFilter({
    required this.categoryId,
    this.subcategory,
  });

  @override
  List<Object?> get props => [categoryId, subcategory];
}
