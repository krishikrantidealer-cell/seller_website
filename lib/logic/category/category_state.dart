import 'package:equatable/equatable.dart';
import '../../data/models/catalog_models.dart';

enum CategoryStatus { initial, loading, loaded, error }

class CategoryState extends Equatable {
  final CategoryStatus status;
  final List<CategoryItem> categories;
  final String selectedCategoryId;
  final String? selectedSubcategory;
  final String? errorMessage;

  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.selectedCategoryId = 'all',
    this.selectedSubcategory,
    this.errorMessage,
  });

  /// Returns the active list of categories, falling back to `CategoryItem.sampleCategories`
  /// during initial 0ms render or when offline.
  List<CategoryItem> get effectiveCategories =>
      categories.isNotEmpty ? categories : CategoryItem.sampleCategories;

  CategoryItem? findCategory(String idOrSlugOrName) {
    if (idOrSlugOrName.isEmpty || idOrSlugOrName == 'all') return null;
    final target = idOrSlugOrName.trim().toLowerCase();
    for (final cat in effectiveCategories) {
      if (cat.id.toLowerCase() == target ||
          (cat.backendId != null && cat.backendId!.toLowerCase() == target) ||
          cat.slug.toLowerCase() == target ||
          cat.name.toLowerCase() == target) {
        return cat;
      }
    }
    return null;
  }

  CategoryState copyWith({
    CategoryStatus? status,
    List<CategoryItem>? categories,
    String? selectedCategoryId,
    String? selectedSubcategory,
    bool clearSelectedSubcategory = false,
    String? errorMessage,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedSubcategory: clearSelectedSubcategory
          ? null
          : (selectedSubcategory ?? this.selectedSubcategory),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        selectedCategoryId,
        selectedSubcategory,
        errorMessage,
      ];
}
