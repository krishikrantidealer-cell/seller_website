import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../network/websocket_service.dart';
import '../storage/token_storage.dart';
import '../../data/datasources/category_local_datasource.dart';
import '../../data/datasources/category_remote_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/repositories/category_repository.dart';

class InjectionContainer {
  static final InjectionContainer instance = InjectionContainer._internal();
  InjectionContainer._internal();

  ApiClient? _apiClient;
  TokenStorage? _tokenStorage;
  CategoryLocalDataSource? _categoryLocalDataSource;
  CategoryRemoteDataSource? _categoryRemoteDataSource;
  CategoryRepository? _categoryRepository;

  Future<void> init({
    http.Client? httpClient,
    SharedPreferences? sharedPreferences,
    String? baseUrl,
    CategoryRepository? mockCategoryRepository,
  }) async {
    if (mockCategoryRepository != null) {
      _categoryRepository = mockCategoryRepository;
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
    _categoryRepository = CategoryRepositoryImpl(
      remoteDataSource: _categoryRemoteDataSource!,
      localDataSource: _categoryLocalDataSource,
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
}
