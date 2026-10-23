import 'package:equatable/equatable.dart';

class ProductImageEntity extends Equatable {
  final String id;
  final int displayOrder;
  final String midUrl;
  final String lowUrl;

  const ProductImageEntity({
    required this.id,
    this.displayOrder = 0,
    required this.midUrl,
    required this.lowUrl,
  });

  String get preferredUrl => midUrl.isNotEmpty ? midUrl : lowUrl;

  @override
  List<Object?> get props => [id, displayOrder, midUrl, lowUrl];
}

class ProductVariantEntity extends Equatable {
  final String id;
  final String label;
  final String unit;
  final double packSize;
  final String packSizeUnit;
  final int packQuantity;
  final double displayRate;
  final double printedMrp;
  final double discountRs;
  final double gstPercentage;
  final int stock;
  final bool isDefault;
  final double? pricePerBaseUnit;

  const ProductVariantEntity({
    required this.id,
    required this.label,
    this.unit = 'ml',
    this.packSize = 1,
    this.packSizeUnit = 'L',
    this.packQuantity = 1,
    required this.displayRate,
    required this.printedMrp,
    this.discountRs = 0.0,
    this.gstPercentage = 0.0,
    this.stock = 100,
    this.isDefault = false,
    this.pricePerBaseUnit,
  });

  int get discountPercentage {
    if (printedMrp <= 0 || displayRate >= printedMrp) return 0;
    return (((printedMrp - displayRate) / printedMrp) * 100).round();
  }

  double get savings => (printedMrp - displayRate).clamp(0.0, double.infinity);

  @override
  List<Object?> get props => [
        id,
        label,
        unit,
        packSize,
        packSizeUnit,
        packQuantity,
        displayRate,
        printedMrp,
        discountRs,
        gstPercentage,
        stock,
        isDefault,
        pricePerBaseUnit,
      ];
}

class ProductEntity extends Equatable {
  final String id;
  final String sku;
  final String title;
  final String? technicalName;
  final String? vendor;
  final String? description;
  final List<ProductImageEntity> productImages;
  final List<String> imageUrls;
  final String? technicalContent;
  final List<String> features;
  final List<String> benefits;
  final String? modeOfAction;
  final List<String> suitableCrops;
  final List<String> targetPests;
  final List<String> targetDiseases;
  final String? dosage;
  final String? applicationMethod;
  final String categoryId;
  final String categoryName;
  final bool isAvailable;
  final bool isFeatured;
  final List<ProductVariantEntity> variants;

  const ProductEntity({
    required this.id,
    required this.sku,
    required this.title,
    this.technicalName,
    this.vendor = 'Essential Bio Crop Science',
    this.description,
    this.productImages = const [],
    this.imageUrls = const [],
    this.technicalContent,
    this.features = const [],
    this.benefits = const [],
    this.modeOfAction,
    this.suitableCrops = const [],
    this.targetPests = const [],
    this.targetDiseases = const [],
    this.dosage,
    this.applicationMethod,
    required this.categoryId,
    this.categoryName = 'Crop Protection',
    this.isAvailable = true,
    this.isFeatured = false,
    required this.variants,
  });

  ProductVariantEntity get defaultVariant {
    if (variants.isEmpty) {
      return const ProductVariantEntity(
        id: 'default',
        label: 'Standard Pack',
        displayRate: 0,
        printedMrp: 0,
      );
    }
    return variants.firstWhere((v) => v.isDefault, orElse: () => variants.first);
  }

  String get primaryImageUrl {
    if (productImages.isNotEmpty) {
      return productImages.first.preferredUrl;
    }
    if (imageUrls.isNotEmpty) {
      return imageUrls.first;
    }
    return '';
  }

  @override
  List<Object?> get props => [
        id,
        sku,
        title,
        technicalName,
        vendor,
        description,
        productImages,
        imageUrls,
        technicalContent,
        features,
        benefits,
        modeOfAction,
        suitableCrops,
        targetPests,
        targetDiseases,
        dosage,
        applicationMethod,
        categoryId,
        categoryName,
        isAvailable,
        isFeatured,
        variants,
      ];
}
