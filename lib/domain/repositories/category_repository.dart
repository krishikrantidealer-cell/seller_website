import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getRootCategories();
  Future<List<CategoryEntity>> getCategoryChildren(String parentId);
  Future<CategoryEntity?> getCategoryById(String categoryId);
}
