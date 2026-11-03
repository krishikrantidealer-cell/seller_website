import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../network/websocket_service.dart';
import '../storage/token_storage.dart';
import '../../data/datasources/category_local_datasource.dart';
import '../../data/datasources/category_remote_datasource.dart';
import '../../data/datasources/product_local_datasource.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/repositories/product_repository.dart';

class InjectionContainer {
  static final InjectionContainer instance = InjectionContainer._internal();
  InjectionContainer._internal();

  ApiClient? _apiClient;
  TokenStorage? _tokenStorage;
  CategoryLocalDataSource? _categoryLocalDataSource;
  CategoryRemoteDataSource? _categoryRemoteDataSource;
  CategoryRepository? _categoryRepository;
  ProductLocalDataSource? _productLocalDataSource;
  ProductRemoteDataSource? _productRemoteDataSource;
  ProductRepository? _productRepository;

  Future<void> init({
    http.Client? httpClient,
    SharedPreferences? sharedPreferences,
    String? baseUrl,
    CategoryRepository? mockCategoryRepository,
    ProductRepository? mockProductRepository,
  }) async {
    if (mockCategoryRepository != null) {
      _categoryRepository = mockCategoryRepository;
    }
    if (mockProductRepository != null) {
      _productRepository = mockProductRepository;
    }
    if (mockCategoryRepository != null && mockProductRepository != null) {
      return;
    }

    final prefs = sharedPreferences ?? await SharedPreferences.getInstance();
    _tokenStorage = TokenStorage(prefs: prefs);
    WebSocketService().setTokenStorage(_tokenStorage!);

    _apiClient = ApiClient(
      client: httpClient,
      tokenStorage: _tokenStorage,
      baseUrl: baseUrl,
    );

    _categoryLocalDataSource = CategoryLocalDataSourceImpl(prefs);
    _categoryRemoteDataSource = CategoryRemoteDataSourceImpl(_apiClient!);
    _categoryRepository ??= CategoryRepositoryImpl(
      remoteDataSource: _categoryRemoteDataSource!,
      localDataSource: _categoryLocalDataSource,
    );

    _productLocalDataSource = ProductLocalDataSourceImpl(prefs);
    _productRemoteDataSource = ProductRemoteDataSourceImpl(_apiClient!);
    _productRepository ??= ProductRepositoryImpl(
      remoteDataSource: _productRemoteDataSource!,
      localDataSource: _productLocalDataSource,
    );

    // Attempt non-blocking WebSocket connection if user session exists
    WebSocketService().connect();
  }

  ApiClient get apiClient => _apiClient ??= ApiClient();
  TokenStorage get tokenStorage => _tokenStorage ??= TokenStorage();

  CategoryRepository get categoryRepository {
    return _categoryRepository ??= CategoryRepositoryImpl(
      remoteDataSource: CategoryRemoteDataSourceImpl(apiClient),
      localDataSource: CategoryLocalDataSourceImpl(),
    );
  }

  ProductRepository get productRepository {
    return _productRepository ??= ProductRepositoryImpl(
      remoteDataSource: ProductRemoteDataSourceImpl(apiClient),
      localDataSource: ProductLocalDataSourceImpl(),
    );
  }
}
