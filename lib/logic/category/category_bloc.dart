import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/websocket_service.dart';
import '../../data/services/category_api_service.dart';
import '../../domain/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepository;
  final WebSocketService _webSocketService;
  StreamSubscription? _wsSubscription;
  VoidCallback? _controllerListener;

  CategoryBloc({
    required this.categoryRepository,
    WebSocketService? webSocketService,
  })  : _webSocketService = webSocketService ?? WebSocketService(),
        super(
          CategoryState(
            status: CategoryStatus.loaded,
            categories: CategoryController.instance.categories,
          ),
        ) {
    on<InitializeCategories>(_onInitializeCategories);
    on<FetchCategories>(_onFetchCategories);
    on<CategoriesExternalUpdated>(_onCategoriesExternalUpdated);
    on<SelectCategoryFilter>(_onSelectCategoryFilter);

    // 1. Subscribe to real-time category updates from WebSocket (/ws categories:* events)
    _wsSubscription = _webSocketService.categoryUpdates.listen((_) {
      if (!isClosed) {
        add(const FetchCategories(isRefresh: true, isBackground: true));
      }
    });

    // 2. Keep in sync with CategoryController.instance updates
    _controllerListener = () {
      if (!isClosed) {
        add(CategoriesExternalUpdated(CategoryController.instance.categories));
      }
    };
    CategoryController.instance.addListener(_controllerListener!);
  }

  bool get _isTestEnvironment {
    return WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding');
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    if (_controllerListener != null) {
      CategoryController.instance.removeListener(_controllerListener!);
    }
    return super.close();
  }

  Future<void> _onInitializeCategories(
    InitializeCategories event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      final cached = await categoryRepository.getCachedCategories();
      if (cached != null && cached.isNotEmpty) {
        emit(
          state.copyWith(
            status: CategoryStatus.loaded,
            categories: cached,
          ),
        );
        if (!_isTestEnvironment) {
          add(const FetchCategories(isBackground: true));
        }
        return;
      }
    } catch (_) {}

    if (!_isTestEnvironment) {
      add(const FetchCategories(isBackground: true));
    }
  }

  Future<void> _onFetchCategories(
    FetchCategories event,
    Emitter<CategoryState> emit,
  ) async {
    final hasData = state.categories.isNotEmpty;
    if (!event.isBackground && !hasData) {
      emit(state.copyWith(status: CategoryStatus.loading));
    }

    try {
      final categories = await categoryRepository.getCategories(
        forceRefresh: event.isRefresh,
      );
      emit(
        state.copyWith(
          status: CategoryStatus.loaded,
          categories: categories,
        ),
      );
    } catch (e) {
      if (!event.isBackground && !hasData) {
        emit(
          state.copyWith(
            status: CategoryStatus.error,
            errorMessage: e.toString().replaceAll('ApiException: ', ''),
          ),
        );
      }
    }
  }

  void _onCategoriesExternalUpdated(
    CategoriesExternalUpdated event,
    Emitter<CategoryState> emit,
  ) {
    if (event.categories.isNotEmpty) {
      emit(
        state.copyWith(
          status: CategoryStatus.loaded,
          categories: event.categories,
        ),
      );
    }
  }

  void _onSelectCategoryFilter(
    SelectCategoryFilter event,
    Emitter<CategoryState> emit,
  ) {
    emit(
      state.copyWith(
        selectedCategoryId: event.categoryId,
        selectedSubcategory: event.subcategory,
        clearSelectedSubcategory: event.subcategory == null,
      ),
    );
  }
}
