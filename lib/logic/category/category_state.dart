import 'package:equatable/equatable.dart';
import '../../domain/entities/category_entity.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoriesLoadedState extends CategoryState {
  final List<CategoryEntity> categories;
  final String selectedCategoryId;
  final String? selectedSubcategory;

  const CategoriesLoadedState({
    required this.categories,
    this.selectedCategoryId = 'all',
    this.selectedSubcategory,
  });

  @override
  List<Object?> get props => [categories, selectedCategoryId, selectedSubcategory];
}

class CategoryErrorState extends CategoryState {
  final String message;

  const CategoryErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
