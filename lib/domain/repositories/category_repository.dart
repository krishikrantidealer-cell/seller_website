import '../../data/models/catalog_models.dart';
import '../../data/services/category_api_service.dart';

abstract class CategoryRepository {
  /// Retrieves the 3-tier `CategoryItem` hierarchy (`Level 0 -> Level 1 -> Level 2`).
  /// Uses local/memory cache first unless [forceRefresh] is true.
  Future<List<CategoryItem>> getCategories({bool forceRefresh = false});

  /// Immediate 0ms cached hierarchy retrieval.
  Future<List<CategoryItem>?> getCachedCategories();

  /// Retrieves a single raw category record by ID.
  Future<ApiCategoryRecord> getCategoryById(String id);
}
