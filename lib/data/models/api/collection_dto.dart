import '../../../domain/entities/collection_entity.dart';

class SubCollectionDto {
  final String id;
  final String name;
  final String slug;
  final bool isActive;
  final String? image;
  final int productCount;

  SubCollectionDto({
    required this.id,
    required this.name,
    required this.slug,
    this.isActive = true,
    this.image,
    this.productCount = 0,
  });

  factory SubCollectionDto.fromJson(Map<String, dynamic> json) {
    return SubCollectionDto(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      isActive: json['isActive'] != false,
      image: json['image']?.toString(),
      productCount: (json['productCount'] is num) ? (json['productCount'] as num).toInt() : 0,
    );
  }

  SubCollectionEntity toEntity() => SubCollectionEntity(
        id: id,
        name: name,
        slug: slug,
        isActive: isActive,
        image: image,
        productCount: productCount,
      );
}

class CollectionDto {
  final String id;
  final String name;
  final String slug;
  final String description;
  final bool isActive;
  final int priority;
  final String? bannerTitle;
  final int productCount;
  final List<SubCollectionDto> subCollections;

  CollectionDto({
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

  factory CollectionDto.fromJson(Map<String, dynamic> json) {
    final rawSubs = json['subCollections'];
    final subList = (rawSubs is List)
        ? rawSubs
            .whereType<Map<String, dynamic>>()
            .map((s) => SubCollectionDto.fromJson(s))
            .toList()
        : <SubCollectionDto>[];

    return CollectionDto(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isActive: json['isActive'] != false,
      priority: (json['priority'] is num) ? (json['priority'] as num).toInt() : 0,
      bannerTitle: json['bannerTitle']?.toString(),
      productCount: (json['productCount'] is num) ? (json['productCount'] as num).toInt() : 0,
      subCollections: subList,
    );
  }

  CollectionEntity toEntity() => CollectionEntity(
        id: id,
        name: name,
        slug: slug,
        description: description,
        isActive: isActive,
        priority: priority,
        bannerTitle: bannerTitle,
        productCount: productCount,
        subCollections: subCollections.map((s) => s.toEntity()).toList(),
      );
}
