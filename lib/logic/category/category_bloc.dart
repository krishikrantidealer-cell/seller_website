import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryBloc(this._categoryRepository) : super(CategoryInitial()) {
    on<FetchCategoriesEvent>(_onFetchCategories);
    on<SelectCategoryEvent>(_onSelectCategory);
  }

  Future<void> _onFetchCategories(FetchCategoriesEvent event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final categories = await _categoryRepository.getRootCategories();
      emit(CategoriesLoadedState(categories: categories));
    } catch (e) {
      emit(CategoryErrorState(e.toString()));
    }
  }

  void _onSelectCategory(SelectCategoryEvent event, Emitter<CategoryState> emit) {
    if (state is CategoriesLoadedState) {
      final current = state as CategoriesLoadedState;
      emit(
        CategoriesLoadedState(
          categories: current.categories,
          selectedCategoryId: event.categoryId,
          selectedSubcategory: event.subcategory,
        ),
      );
    }
  }
}
