import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/catalog_models.dart';
import '../services/category_api_service.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;
  final CategoryLocalDataSource? localDataSource;
  List<CategoryItem>? _memoryHierarchyCache;

  CategoryRepositoryImpl({
    required this.remoteDataSource,
    this.localDataSource,
  });

  @override
  Future<List<CategoryItem>> getCategories({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      if (_memoryHierarchyCache != null && _memoryHierarchyCache!.isNotEmpty) {
        _syncInBackground();
        return _memoryHierarchyCache!;
      }
      final cachedRecords = await localDataSource?.getCachedRecords();
      if (cachedRecords != null && cachedRecords.isNotEmpty) {
        final built = CategoryController.buildCategoryHierarchy(cachedRecords);
        if (built.isNotEmpty) {
          _memoryHierarchyCache = built;
          _syncInBackground();
          return built;
        }
      }
    }

    final records = await remoteDataSource.getCategories();
    await localDataSource?.cacheRecords(records);
    final hierarchy = CategoryController.buildCategoryHierarchy(records);
    _memoryHierarchyCache = hierarchy;
    CategoryController.instance.syncFromBloc(hierarchy);
    return hierarchy;
  }

  void _syncInBackground() async {
    try {
      final freshRecords = await remoteDataSource.getCategories();
      await localDataSource?.cacheRecords(freshRecords);
      final built = CategoryController.buildCategoryHierarchy(freshRecords);
      if (built.isNotEmpty) {
        _memoryHierarchyCache = built;
        CategoryController.instance.syncFromBloc(built);
      }
    } catch (_) {}
  }

  @override
  Future<List<CategoryItem>?> getCachedCategories() async {
    if (_memoryHierarchyCache != null && _memoryHierarchyCache!.isNotEmpty) {
      return _memoryHierarchyCache;
    }
    final cachedRecords = await localDataSource?.getCachedRecords();
    if (cachedRecords != null && cachedRecords.isNotEmpty) {
      final built = CategoryController.buildCategoryHierarchy(cachedRecords);
      if (built.isNotEmpty) {
        _memoryHierarchyCache = built;
        return built;
      }
    }
    return null;
  }

  @override
  Future<ApiCategoryRecord> getCategoryById(String id) {
    return remoteDataSource.getCategoryById(id);
  }
}
