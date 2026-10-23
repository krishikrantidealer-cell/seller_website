import 'package:equatable/equatable.dart';

class SubCollectionEntity extends Equatable {
  final String id;
  final String name;
  final String slug;
  final bool isActive;
  final String? image;
  final int productCount;

  const SubCollectionEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.isActive = true,
    this.image,
    this.productCount = 0,
  });

  @override
  List<Object?> get props => [id, name, slug, isActive, image, productCount];
}

class CollectionEntity extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String description;
  final bool isActive;
  final int priority;
  final String? bannerTitle;
  final int productCount;
  final List<SubCollectionEntity> subCollections;

  const CollectionEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    this.isActive = true,
    this.priority = 0,
    this.bannerTitle,
    this.productCount = 0,
    this.subCollections = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        isActive,
        priority,
        bannerTitle,
        productCount,
        subCollections,
      ];
}
