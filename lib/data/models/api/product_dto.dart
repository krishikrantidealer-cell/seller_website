import '../../../domain/entities/product_entity.dart';

class ProductImageDto {
  final String id;
  final int displayOrder;
  final String midUrl;
  final String lowUrl;

  ProductImageDto({
    required this.id,
    this.displayOrder = 0,
    required this.midUrl,
    required this.lowUrl,
  });

  factory ProductImageDto.fromJson(Map<String, dynamic> json) {
    return ProductImageDto(
      id: json['id']?.toString() ?? '',
      displayOrder: (json['displayOrder'] is num) ? (json['displayOrder'] as num).toInt() : 0,
      midUrl: json['midUrl']?.toString() ?? '',
      lowUrl: json['lowUrl']?.toString() ?? '',
    );
  }

  ProductImageEntity toEntity() => ProductImageEntity(
        id: id,
        displayOrder: displayOrder,
        midUrl: midUrl,
        lowUrl: lowUrl,
      );
}

class ProductVariantDto {
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

  ProductVariantDto({
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

  factory ProductVariantDto.fromJson(Map<String, dynamic> json) {
    return ProductVariantDto(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Standard Pack',
      unit: json['unit']?.toString() ?? 'ml',
      packSize: (json['packSize'] is num) ? (json['packSize'] as num).toDouble() : 1.0,
      packSizeUnit: json['packSizeUnit']?.toString() ?? 'L',
      packQuantity: (json['packQuantity'] is num) ? (json['packQuantity'] as num).toInt() : 1,
      displayRate: (json['displayRate'] is num) ? (json['displayRate'] as num).toDouble() : 0.0,
      printedMrp: (json['printedMrp'] is num) ? (json['printedMrp'] as num).toDouble() : 0.0,
      discountRs: (json['discountRs'] is num) ? (json['discountRs'] as num).toDouble() : 0.0,
      gstPercentage: (json['gstPercentage'] is num) ? (json['gstPercentage'] as num).toDouble() : 0.0,
      stock: (json['stock'] is num) ? (json['stock'] as num).toInt() : 100,
      isDefault: json['isDefault'] == true,
      pricePerBaseUnit: (json['pricePerBaseUnit'] is num) ? (json['pricePerBaseUnit'] as num).toDouble() : null,
    );
  }

  ProductVariantEntity toEntity() => ProductVariantEntity(
        id: id,
        label: label,
        unit: unit,
        packSize: packSize,
        packSizeUnit: packSizeUnit,
        packQuantity: packQuantity,
        displayRate: displayRate,
        printedMrp: printedMrp > 0 ? printedMrp : displayRate,
        discountRs: discountRs,
        gstPercentage: gstPercentage,
        stock: stock,
        isDefault: isDefault,
        pricePerBaseUnit: pricePerBaseUnit,
      );
}

class ProductDto {
  final String id;
  final String sku;
  final String title;
  final String? technicalName;
  final String? vendor;
  final String? description;
  final List<ProductImageDto> productImages;
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
  final bool isAvailable;
  final bool isFeatured;
  final List<ProductVariantDto> variants;

  ProductDto({
    required this.id,
    required this.sku,
    required this.title,
    this.technicalName,
    this.vendor,
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
    this.isAvailable = true,
    this.isFeatured = false,
    required this.variants,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    final rawProductImages = json['productImages'];
    final productImagesList = (rawProductImages is List)
        ? rawProductImages
            .whereType<Map<String, dynamic>>()
            .map((img) => ProductImageDto.fromJson(img))
            .toList()
        : <ProductImageDto>[];

    final rawImages = json['images'];
    final imagesList = (rawImages is List)
        ? rawImages.map((e) => e.toString()).toList()
        : <String>[];

    final rawVariants = json['variants'];
    final variantsList = (rawVariants is List)
        ? rawVariants
            .whereType<Map<String, dynamic>>()
            .map((v) => ProductVariantDto.fromJson(v))
            .toList()
        : <ProductVariantDto>[];

    List<String> parseStringList(dynamic field) {
      if (field is List) {
        return field.map((e) => e.toString()).toList();
      }
      return [];
    }

    return ProductDto(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      technicalName: json['technicalName']?.toString(),
      vendor: json['vendor']?.toString() ?? 'Essential Bio Crop Science',
      description: json['description']?.toString(),
      productImages: productImagesList,
      imageUrls: imagesList,
      technicalContent: json['technicalContent']?.toString(),
      features: parseStringList(json['features']),
      benefits: parseStringList(json['benefits']),
      modeOfAction: json['modeOfAction']?.toString(),
      suitableCrops: parseStringList(json['suitableCrops']),
      targetPests: parseStringList(json['targetPests']),
      targetDiseases: parseStringList(json['targetDiseases']),
      dosage: json['dosage']?.toString(),
      applicationMethod: json['applicationMethod']?.toString(),
      categoryId: json['categoryId']?.toString() ?? '',
      isAvailable: json['isAvailable'] != false,
      isFeatured: json['isFeatured'] == true,
      variants: variantsList,
    );
  }

  ProductEntity toEntity() => ProductEntity(
        id: id,
        sku: sku,
        title: title,
        technicalName: technicalName,
        vendor: vendor ?? 'Essential Bio Crop Science',
        description: description,
        productImages: productImages.map((i) => i.toEntity()).toList(),
        imageUrls: imageUrls,
        technicalContent: technicalContent,
        features: features,
        benefits: benefits,
        modeOfAction: modeOfAction,
        suitableCrops: suitableCrops,
        targetPests: targetPests,
        targetDiseases: targetDiseases,
        dosage: dosage,
        applicationMethod: applicationMethod,
        categoryId: categoryId,
        isAvailable: isAvailable,
        isFeatured: isFeatured,
        variants: variants.map((v) => v.toEntity()).toList(),
      );
}
