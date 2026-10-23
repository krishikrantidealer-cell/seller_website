import '../../../domain/entities/category_entity.dart';

class CategoryDto {
  final String id;
  final String name;
  final String slug;
  final String? parentId;
  final int level;
  final int sortOrder;
  final bool isActive;

  CategoryDto({
    required this.id,
    required this.name,
    required this.slug,
    this.parentId,
    this.level = 0,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      parentId: json['parentId']?.toString(),
      level: (json['level'] is num) ? (json['level'] as num).toInt() : 0,
      sortOrder: (json['sortOrder'] is num) ? (json['sortOrder'] as num).toInt() : 0,
      isActive: json['isActive'] == true,
    );
  }

  static String mapIcon(String slug) {
    switch (slug.toLowerCase()) {
      case 'crop-protection':
        return '🛡️';
      case 'crop-nutrition':
        return '🌱';
      case 'fertilizers':
        return '🧪';
      case 'seeds':
        return '🌾';
      case 'equipments':
        return '🚜';
      case 'irrigation':
        return '💧';
      case 'gardening':
        return '🏡';
      case 'cattle-and-bird-care':
        return '🐄';
      case 'organic-farming':
        return '🌿';
      case 'har-din-sasta':
        return '⚡';
      case 'bulk':
        return '📦';
      case 'insecticides':
        return '🐛';
      default:
        return '🍃';
    }
  }

  CategoryEntity toEntity() => CategoryEntity(
        id: id,
        name: name,
        slug: slug,
        parentId: parentId,
        level: level,
        sortOrder: sortOrder,
        isActive: isActive,
        icon: mapIcon(slug),
      );
}
