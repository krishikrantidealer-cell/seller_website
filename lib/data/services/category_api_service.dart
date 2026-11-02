import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../models/catalog_models.dart';

/// DTO representing a raw category record returned from `GET /api/v1/categories`.
class ApiCategoryRecord {
  final String id;
  final String name;
  final String slug;
  final String? parentId;
  final int level;
  final int sortOrder;
  final bool isActive;
  final String? bannerImage;
  final String? cataloguePdf;
  final String? categoryImageUrl;
  final String? bannerTitle;

  const ApiCategoryRecord({
    required this.id,
    required this.name,
    required this.slug,
    this.parentId,
    required this.level,
    required this.sortOrder,
    required this.isActive,
    this.bannerImage,
    this.cataloguePdf,
    this.categoryImageUrl,
    this.bannerTitle,
  });

  factory ApiCategoryRecord.fromJson(Map<String, dynamic> json) {
    final rawName = (json['name'] ?? '').toString().trim();
    final rawSlug = (json['slug'] ?? '').toString().trim();
    return ApiCategoryRecord(
      id: (json['id'] ?? json['_id'] ?? '').toString().trim(),
      name: rawName,
      slug: rawSlug.isNotEmpty
          ? rawSlug
          : rawName
              .toLowerCase()
              .replaceAll('&', 'and')
              .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
              .replaceAll(RegExp(r'^-+|-+$'), ''),
      parentId: json['parentId']?.toString().trim().isEmpty == true
          ? null
          : json['parentId']?.toString().trim(),
      level: (json['level'] is num)
          ? (json['level'] as num).toInt()
          : int.tryParse('${json['level'] ?? 0}') ?? 0,
      sortOrder: (json['sortOrder'] is num)
          ? (json['sortOrder'] as num).toInt()
          : int.tryParse('${json['sortOrder'] ?? json['displayOrder'] ?? 0}') ?? 0,
      isActive: json['isActive'] != false,
      bannerImage: json['bannerImage']?.toString(),
      cataloguePdf: json['cataloguePdf']?.toString(),
      categoryImageUrl: json['categoryImageUrl']?.toString(),
      bannerTitle: json['bannerTitle']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'parentId': parentId,
      'level': level,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'bannerImage': bannerImage,
      'cataloguePdf': cataloguePdf,
      'categoryImageUrl': categoryImageUrl,
      'bannerTitle': bannerTitle,
    };
  }
}

/// Centralized controller and API service for fetching and managing the 3-tier
/// Category Hierarchy (`Level 0 Major Category -> Level 1 CategoryGroup -> Level 2 Subcategories`)
/// from `GET /api/v1/categories`.
class CategoryController extends ChangeNotifier {
  static final CategoryController instance = CategoryController._internal();
  CategoryController._internal();

  List<CategoryItem> _categories = CategoryItem.sampleCategories;
  bool _isLoading = false;
  bool _hasLoadedFromApi = false;
  String? _errorMessage;

  /// Current active 3-tier category hierarchy (defaults to `CategoryItem.sampleCategories`
  /// until the backend response resolves, or if offline).
  List<CategoryItem> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get hasLoadedFromApi => _hasLoadedFromApi;
  String? get errorMessage => _errorMessage;

  /// Finds a Level 0 `CategoryItem` by its `id`, `backendId`, `slug`, or `name`.
  CategoryItem? findCategory(String idOrSlugOrName) {
    if (idOrSlugOrName.isEmpty || idOrSlugOrName == 'all') return null;
    final target = idOrSlugOrName.trim().toLowerCase();
    for (final cat in _categories) {
      if (cat.id.toLowerCase() == target ||
          (cat.backendId != null && cat.backendId!.toLowerCase() == target) ||
          cat.slug.toLowerCase() == target ||
          cat.name.toLowerCase() == target) {
        return cat;
      }
    }
    return null;
  }

  /// Fetches all active categories from `GET /api/v1/categories` and builds the
  /// 3-tier hierarchy (`Level 0 -> Level 1 -> Level 2`).
  Future<void> fetchCategories({
    http.Client? client,
    bool forceRefresh = false,
  }) async {
    if (_isLoading) return;
    if (_hasLoadedFromApi && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;

    final httpClient = client ?? http.Client();
    final shouldCloseClient = client == null;

    try {
      final List<ApiCategoryRecord> allRecords = [];
      int currentPage = 0;
      int totalPages = 1;

      while (currentPage < totalPages && currentPage < 10) {
        final uri = Uri.parse(
          '${AppConstants.apiBaseUrl}/categories?page=$currentPage&size=500',
        );
        final response = await httpClient
            .get(uri, headers: const {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 8));

        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception('HTTP ${response.statusCode} when fetching categories');
        }

        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Invalid category response envelope');
        }

        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          final content = data['content'];
          if (content is List) {
            for (final item in content) {
              if (item is Map<String, dynamic>) {
                allRecords.add(ApiCategoryRecord.fromJson(item));
              } else if (item is Map) {
                allRecords.add(
                  ApiCategoryRecord.fromJson(Map<String, dynamic>.from(item)),
                );
              }
            }
          }
          final isLast = data['last'] == true;
          final reportedTotalPages = (data['totalPages'] is num)
              ? (data['totalPages'] as num).toInt()
              : 1;
          totalPages = reportedTotalPages;
          if (isLast || content is! List || content.isEmpty) {
            break;
          }
          currentPage++;
        } else if (data is List) {
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              allRecords.add(ApiCategoryRecord.fromJson(item));
            } else if (item is Map) {
              allRecords.add(
                ApiCategoryRecord.fromJson(Map<String, dynamic>.from(item)),
              );
            }
          }
          break;
        } else {
          break;
        }
      }

      final builtTree = buildCategoryHierarchy(allRecords);
      if (builtTree.isNotEmpty) {
        _categories = builtTree;
        _hasLoadedFromApi = true;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (shouldCloseClient) {
        httpClient.close();
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pure helper to assemble flat `ApiCategoryRecord` items (levels 0, 1, 2) into
  /// the 3-tier `List<CategoryItem>` tree used by the Home screen & CategoryRibbon.
  static List<CategoryItem> buildCategoryHierarchy(
    List<ApiCategoryRecord> records,
  ) {
    final activeRecords = records
        .where((r) => r.isActive && r.id.isNotEmpty && r.name.isNotEmpty)
        .toList();
    if (activeRecords.isEmpty) return const [];

    // Separate by level
    final l0Records = activeRecords
        .where((r) => r.level == 0 || r.parentId == null)
        .toList();
    final l1ByParent = <String, List<ApiCategoryRecord>>{};
    final l2ByParent = <String, List<ApiCategoryRecord>>{};

    for (final rec in activeRecords) {
      if (rec.level == 1 && rec.parentId != null) {
        l1ByParent.putIfAbsent(rec.parentId!, () => []).add(rec);
      } else if (rec.level == 2 && rec.parentId != null) {
        l2ByParent.putIfAbsent(rec.parentId!, () => []).add(rec);
      }
    }

    int compareRecords(ApiCategoryRecord a, ApiCategoryRecord b) {
      final orderCmp = a.sortOrder.compareTo(b.sortOrder);
      if (orderCmp != 0) return orderCmp;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    }

    l0Records.sort(compareRecords);
    for (final list in l1ByParent.values) {
      list.sort(compareRecords);
    }
    for (final list in l2ByParent.values) {
      list.sort(compareRecords);
    }

    final List<CategoryItem> result = [];
    for (final l0 in l0Records) {
      final l1List = l1ByParent[l0.id] ?? const <ApiCategoryRecord>[];
      final List<CategoryGroup> groups = [];

      for (final l1 in l1List) {
        final l2List = l2ByParent[l1.id] ?? const <ApiCategoryRecord>[];
        final subItems = l2List
            .map(
              (l2) => CategorySubItem(
                id: l2.id,
                name: l2.name,
                slug: l2.slug,
                categoryImageUrl: l2.categoryImageUrl,
                sortOrder: l2.sortOrder,
              ),
            )
            .toList();

        groups.add(
          CategoryGroup(
            id: l1.id,
            slug: l1.slug,
            name: l1.name,
            icon: CategoryItem.iconForSubcategory(l1.name, parentName: l0.name),
            categoryImageUrl: l1.categoryImageUrl,
            sortOrder: l1.sortOrder,
            subcategories: subItems.map((s) => s.name).toList(),
            subcategoryItems: subItems,
          ),
        );
      }

      result.add(
        CategoryItem(
          id: l0.slug.isNotEmpty ? l0.slug : l0.id,
          backendId: l0.id,
          slug: l0.slug,
          name: l0.name,
          icon: CategoryItem.iconForMajorCategory(l0.name),
          categoryImageUrl: l0.categoryImageUrl,
          bannerImage: l0.bannerImage,
          bannerTitle: l0.bannerTitle,
          sortOrder: l0.sortOrder,
          groups: groups,
        ),
      );
    }

    return result;
  }

  /// Synchronizes the controller state when `CategoryBloc` emits new categories.
  void syncFromBloc(List<CategoryItem> items) {
    if (items.isEmpty) return;
    _categories = items;
    _hasLoadedFromApi = true;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Resets the controller to fallback sample categories (useful for isolated widget tests).
  @visibleForTesting
  void resetToSampleCategories() {
    _categories = CategoryItem.sampleCategories;
    _isLoading = false;
    _hasLoadedFromApi = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Directly sets categories (useful for unit/widget testing API states).
  @visibleForTesting
  void setCategoriesForTesting(List<CategoryItem> items) {
    _categories = items;
    _hasLoadedFromApi = true;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
