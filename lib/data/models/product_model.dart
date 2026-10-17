import 'package:equatable/equatable.dart';

class PackVariant extends Equatable {
  final String id;
  final String label;
  final double mrp;
  final double sellingPrice;
  final int stock;

  const PackVariant({
    required this.id,
    required this.label,
    required this.mrp,
    required this.sellingPrice,
    required this.stock,
  });

  int get discountPercent {
    if (mrp <= 0 || sellingPrice >= mrp) return 0;
    return (((mrp - sellingPrice) / mrp) * 100).round();
  }

  double get savings => mrp - sellingPrice;

  @override
  List<Object?> get props => [id, label, mrp, sellingPrice, stock];
}

class ProductModel extends Equatable {
  final String id;
  final String title;
  final String brand;
  final String technicalName;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final bool isOrganic;
  final String suitableCrops;
  final String targetPests;
  final String dosage;
  final List<PackVariant> variants;

  const ProductModel({
    required this.id,
    required this.title,
    required this.brand,
    required this.technicalName,
    required this.category,
    required this.imageUrl,
    this.rating = 4.8,
    this.reviewCount = 124,
    this.isOrganic = false,
    required this.suitableCrops,
    required this.targetPests,
    required this.dosage,
    required this.variants,
  });

  PackVariant get defaultVariant => variants.isNotEmpty
      ? variants.first
      : const PackVariant(id: '0', label: '1 Unit', mrp: 0, sellingPrice: 0, stock: 0);

  @override
  List<Object?> get props => [
        id,
        title,
        brand,
        technicalName,
        category,
        imageUrl,
        rating,
        reviewCount,
        isOrganic,
        suitableCrops,
        targetPests,
        dosage,
        variants,
      ];
}
