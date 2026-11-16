import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/websocket_service.dart';
import '../models/catalog_models.dart';

class StoreSubCollection {
  final String id;
  final String name;
  final String slug;
  final bool isActive;
  final String? image;
  final int productCount;

  const StoreSubCollection({
    required this.id,
    required this.name,
    required this.slug,
    this.isActive = true,
    this.image,
    this.productCount = 0,
  });

  factory StoreSubCollection.fromJson(Map<String, dynamic> json) {
    return StoreSubCollection(
      id: (json['id'] ?? json['_id'] ?? '').toString().trim(),
      name: (json['name'] ?? '').toString().trim(),
      slug: (json['slug'] ?? '').toString().trim(),
      isActive: json['isActive'] != false,
      image: json['image']?.toString(),
      productCount: (json['productCount'] is num)
          ? (json['productCount'] as num).toInt()
          : int.tryParse('${json['productCount'] ?? 0}') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'isActive': isActive,
        if (image != null) 'image': image,
        'productCount': productCount,
      };
}

class StoreCollection {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String? image;
  final bool isActive;
  final int priority;
  final List<StoreSubCollection> subCollections;
  final int productCount;
  final String? bannerTitle;

  const StoreCollection({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    this.image,
    this.isActive = true,
    this.priority = 0,
    this.subCollections = const [],
    this.productCount = 0,
    this.bannerTitle,
  });

  factory StoreCollection.fromJson(Map<String, dynamic> json) {
    final rawSubs = json['subCollections'] as List<dynamic>? ?? const [];
    final subs = rawSubs
        .whereType<Map<String, dynamic>>()
        .map(StoreSubCollection.fromJson)
        .where((s) => s.isActive && s.name.isNotEmpty)
        .toList();

    return StoreCollection(
      id: (json['id'] ?? json['_id'] ?? '').toString().trim(),
      name: (json['name'] ?? '').toString().trim(),
      slug: (json['slug'] ?? '').toString().trim(),
      description: (json['description'] ?? '').toString().trim(),
      image: json['image']?.toString(),
      isActive: json['isActive'] != false,
      priority: (json['priority'] is num)
          ? (json['priority'] as num).toInt()
          : int.tryParse('${json['priority'] ?? 0}') ?? 0,
      subCollections: subs,
      productCount: (json['productCount'] is num)
          ? (json['productCount'] as num).toInt()
          : int.tryParse('${json['productCount'] ?? 0}') ?? 0,
      bannerTitle: json['bannerTitle']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'description': description,
        if (image != null) 'image': image,
        'isActive': isActive,
        'priority': priority,
        'subCollections': subCollections.map((s) => s.toJson()).toList(),
        'productCount': productCount,
        if (bannerTitle != null) 'bannerTitle': bannerTitle,
      };

  /// Returns true if [product] belongs to this collection or any of its sub-collections.
  bool matchesProduct(ProductItem product) {
    if (product.assignedCollections.isEmpty) return false;
    final keys = <String>{
      if (id.isNotEmpty) id.toLowerCase(),
      if (name.isNotEmpty) name.toLowerCase(),
      if (slug.isNotEmpty) slug.toLowerCase(),
      for (final sub in subCollections) ...[
        if (sub.id.isNotEmpty) sub.id.toLowerCase(),
        if (sub.name.isNotEmpty) sub.name.toLowerCase(),
        if (sub.slug.isNotEmpty) sub.slug.toLowerCase(),
      ],
    };
    return product.assignedCollections.any((c) => keys.contains(c.trim().toLowerCase()));
  }

  bool matchesSubCollection(ProductItem product, StoreSubCollection sub) {
    if (product.assignedCollections.isEmpty) return false;
    final keys = <String>{
      if (sub.id.isNotEmpty) sub.id.toLowerCase(),
      if (sub.name.isNotEmpty) sub.name.toLowerCase(),
      if (sub.slug.isNotEmpty) sub.slug.toLowerCase(),
    };
    return product.assignedCollections.any((c) => keys.contains(c.trim().toLowerCase()));
  }
}

class CollectionController extends ChangeNotifier with WidgetsBindingObserver {
  static const String _cacheKey = 'seller_website_live_collections_v1';

  CollectionController._() {
    _wsSubscription = WebSocketService().collectionUpdates.listen(_handleCollectionEvent);
    if (!_isTestEnvironment) {
      WidgetsBinding.instance.addObserver(this);
      _fallbackSyncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        if (!WebSocketService().isConnected) {
          fetchCollections(forceRefresh: true);
        }
      });
    }
  }

  static final CollectionController instance = CollectionController._();

  final List<StoreCollection> _collections = [];
  bool _isLoading = false;
  bool _hasFetched = false;
  bool _hasLoadedLocalCache = false;
  bool _pendingForceRefresh = false;
  String? _errorMessage;
  StreamSubscription<Map<String, dynamic>>? _wsSubscription;
  Timer? _fallbackSyncTimer;

  List<StoreCollection> get collections => List.unmodifiable(_collections);
  bool get isLoading => _isLoading;
  bool get hasFetched => _hasFetched;
  String? get errorMessage => _errorMessage;

  bool get _isTestEnvironment {
    try {
      return WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding');
    } catch (_) {
      return false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchCollections(forceRefresh: true);
    }
  }

  void _handleCollectionEvent(Map<String, dynamic> envelope) {
    final event = envelope['event']?.toString();
    final data = envelope['data'];
    if (data is Map<String, dynamic>) {
      final collectionId = (data['collectionId'] ?? data['id'] ?? '').toString().trim();
      final isDeactivated = event == 'collections:delete' || data['isActive'] == false;
      if (collectionId.isNotEmpty && isDeactivated) {
        final beforeLen = _collections.length;
        _collections.removeWhere((c) => c.id == collectionId);
        if (_collections.length != beforeLen) {
          unawaited(_saveCachedCollections(_collections));
          notifyListeners();
        }
      } else if (data['collection'] is Map<String, dynamic>) {
        final updated = StoreCollection.fromJson(data['collection'] as Map<String, dynamic>);
        if (updated.isActive && updated.name.isNotEmpty) {
          final idx = _collections.indexWhere((c) => c.id == updated.id);
          if (idx >= 0) {
            _collections[idx] = updated;
          } else {
            _collections.add(updated);
          }
          _collections.sort((a, b) => a.priority.compareTo(b.priority));
          _hasFetched = true;
          unawaited(_saveCachedCollections(_collections));
          notifyListeners();
        }
      }
    }
    fetchCollections(forceRefresh: true);
  }

  Future<void> _loadCachedCollections() async {
    if (_hasLoadedLocalCache || _isTestEnvironment) return;
    _hasLoadedLocalCache = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final cached = decoded
          .whereType<Map<String, dynamic>>()
          .map(StoreCollection.fromJson)
          .where((c) => c.isActive && c.name.isNotEmpty)
          .toList()
        ..sort((a, b) => a.priority.compareTo(b.priority));
      if (cached.isNotEmpty && _collections.isEmpty && !_hasFetched) {
        _collections
          ..clear()
          ..addAll(cached);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _saveCachedCollections(List<StoreCollection> items) async {
    if (_isTestEnvironment) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey,
        jsonEncode(items.map((c) => c.toJson()).toList()),
      );
    } catch (_) {}
  }

  Future<void> fetchCollections({bool forceRefresh = false}) async {
    if (_isLoading) {
      if (forceRefresh) {
        _pendingForceRefresh = true;
      }
      return;
    }
    if (_hasFetched && !forceRefresh) return;

    await _loadCachedCollections();

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final baseUri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.collections}');
      final uri = forceRefresh
          ? baseUri.replace(queryParameters: {
              ...baseUri.queryParameters,
              '_t': DateTime.now().millisecondsSinceEpoch.toString(),
            })
          : baseUri;
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          if (forceRefresh) ...{
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
          },
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        final rawData = (decoded is Map<String, dynamic>) ? decoded['data'] : decoded;
        List<dynamic> rawItems = const [];
        if (rawData is List) {
          rawItems = rawData;
        } else if (rawData is Map<String, dynamic>) {
          rawItems = (rawData['items'] ?? rawData['content'] ?? rawData['collections'] ?? const [])
              as List<dynamic>;
        }

        final parsed = rawItems
            .whereType<Map<String, dynamic>>()
            .map(StoreCollection.fromJson)
            .where((c) => c.isActive && c.name.isNotEmpty)
            .toList()
          ..sort((a, b) => a.priority.compareTo(b.priority));

        _collections
          ..clear()
          ..addAll(parsed);
        _hasFetched = true;
        _errorMessage = null;
        await _saveCachedCollections(_collections);
      } else {
        _errorMessage = 'Failed to load collections (HTTP ${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'Could not load collections';
    } finally {
      _isLoading = false;
      notifyListeners();
      if (_pendingForceRefresh) {
        _pendingForceRefresh = false;
        unawaited(fetchCollections(forceRefresh: true));
      }
    }
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _fallbackSyncTimer?.cancel();
    if (!_isTestEnvironment) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }
}
