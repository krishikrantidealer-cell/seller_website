import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/api/category_dto.dart';
import '../models/catalog_models.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;

  CategoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<CategoryEntity>> getRootCategories() async {
    try {
      final list = await _remoteDataSource.getRootCategories();
      if (list.isNotEmpty) {
        return list
            .whereType<Map<String, dynamic>>()
            .map((json) => CategoryDto.fromJson(json).toEntity())
            .toList();
      }
    } catch (_) {}

    // Fallback to local sample categories
    return CategoryItem.sampleCategories
        .map(
          (c) => CategoryEntity(
            id: c.id,
            name: c.name,
            slug: c.id,
            icon: c.icon,
            children: c.groups
                .map(
                  (g) => CategoryEntity(
                    id: g.name.toLowerCase().replaceAll(' ', '-'),
                    name: g.name,
                    slug: g.name.toLowerCase().replaceAll(' ', '-'),
                    icon: g.icon,
                    parentId: c.id,
                    level: 1,
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  @override
  Future<List<CategoryEntity>> getCategoryChildren(String parentId) async {
    try {
      final list = await _remoteDataSource.getCategoryChildren(parentId);
      if (list.isNotEmpty) {
        return list
            .whereType<Map<String, dynamic>>()
            .map((json) => CategoryDto.fromJson(json).toEntity())
            .toList();
      }
    } catch (_) {}

    final sample = CategoryItem.sampleCategories.firstWhere(
      (c) => c.id == parentId,
      orElse: () => CategoryItem(id: parentId, name: parentId, icon: '🌿'),
    );

    return sample.groups
        .map(
          (g) => CategoryEntity(
            id: g.name.toLowerCase().replaceAll(' ', '-'),
            name: g.name,
            slug: g.name.toLowerCase().replaceAll(' ', '-'),
            icon: g.icon,
            parentId: parentId,
            level: 1,
          ),
        )
        .toList();
  }

  @override
  Future<CategoryEntity?> getCategoryById(String categoryId) async {
    try {
      final data = await _remoteDataSource.getCategoryById(categoryId);
      if (data.isNotEmpty) {
        return CategoryDto.fromJson(data).toEntity();
      }
    } catch (_) {}

    final roots = await getRootCategories();
    return roots.firstWhere(
      (c) => c.id == categoryId || c.slug == categoryId,
      orElse: () => CategoryEntity(
        id: categoryId,
        name: categoryId,
        slug: categoryId,
        icon: '🌿',
      ),
    );
  }
}
