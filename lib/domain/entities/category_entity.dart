import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String? parentId;
  final int level;
  final int sortOrder;
  final bool isActive;
  final String? icon;
  final List<CategoryEntity> children;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.parentId,
    this.level = 0,
    this.sortOrder = 0,
    this.isActive = true,
    this.icon,
    this.children = const [],
  });

  CategoryEntity copyWith({
    String? id,
    String? name,
    String? slug,
    String? parentId,
    int? level,
    int? sortOrder,
    bool? isActive,
    String? icon,
    List<CategoryEntity>? children,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      parentId: parentId ?? this.parentId,
      level: level ?? this.level,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      icon: icon ?? this.icon,
      children: children ?? this.children,
    );
  }

  @override
  List<Object?> get props => [id, name, slug, parentId, level, sortOrder, isActive, icon, children];
}
