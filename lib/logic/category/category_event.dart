import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class FetchCategoriesEvent extends CategoryEvent {}

class SelectCategoryEvent extends CategoryEvent {
  final String categoryId;
  final String? subcategory;

  const SelectCategoryEvent({required this.categoryId, this.subcategory});

  @override
  List<Object?> get props => [categoryId, subcategory];
}
