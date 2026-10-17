class ProductVariant {
  final String id;
  final String label;
  final double displayRate;
  final double printedMrp;
  final bool inStock;

  const ProductVariant({
    required this.id,
    required this.label,
    required this.displayRate,
    required this.printedMrp,
    this.inStock = true,
  });

  int get discountPercent {
    if (printedMrp <= 0 || displayRate >= printedMrp) return 0;
    return (((printedMrp - displayRate) / printedMrp) * 100).round();
  }
}

class ProductItem {
  final String id;
  final String title;
  final String technicalName;
  final String vendor;
  final String imageUrl;
  final double displayRate;
  final double printedMrp;
  final double rating;
  final int reviewsCount;
  final String category;
  final String packSize;
  final bool isAvailable;
  final bool isBestSeller;
  final List<ProductVariant> variants;

  const ProductItem({
    required this.id,
    required this.title,
    required this.technicalName,
    required this.vendor,
    required this.imageUrl,
    required this.displayRate,
    required this.printedMrp,
    this.rating = 4.8,
    this.reviewsCount = 42,
    required this.category,
    required this.packSize,
    this.isAvailable = true,
    this.isBestSeller = false,
    this.variants = const [],
  });

  int get discountPercent {
    if (printedMrp <= 0 || displayRate >= printedMrp) return 0;
    return (((printedMrp - displayRate) / printedMrp) * 100).round();
  }

  ProductVariant get defaultVariant {
    if (variants.isNotEmpty) return variants.first;
    return ProductVariant(
      id: '${id}_def',
      label: packSize,
      displayRate: displayRate,
      printedMrp: printedMrp,
    );
  }

  static List<ProductItem> get sampleProducts => const [
    ProductItem(
      id: 'PROD-001',
      title: 'Katyayani All in One Insecticide for Crops',
      technicalName: 'Chlorantraniliprole 18.5% SC',
      vendor: 'Katyayani Organics',
      imageUrl: 'https://dujjhct8zer0r.cloudfront.net/images/prod_image/katyayani-all-in-one.webp',
      displayRate: 850,
      printedMrp: 1199,
      category: 'Insecticides',
      packSize: '250 ml',
      isBestSeller: true,
      variants: [
        ProductVariant(id: 'v1_1', label: '100 ml', displayRate: 380, printedMrp: 520),
        ProductVariant(id: 'v1_2', label: '250 ml', displayRate: 850, printedMrp: 1199),
        ProductVariant(id: 'v1_3', label: '500 ml', displayRate: 1599, printedMrp: 2199),
        ProductVariant(id: 'v1_4', label: '1 Ltr', displayRate: 2950, printedMrp: 4100),
      ],
    ),
    ProductItem(
      id: 'PROD-002',
      title: 'Multiplex Bio-Fertilizer Organic Soil Booster',
      technicalName: 'Mycorrhiza Bio Fertilizer VAM',
      vendor: 'Multiplex Group',
      imageUrl: 'https://dujjhct8zer0r.cloudfront.net/images/prod_image/multiplex-soil.webp',
      displayRate: 420,
      printedMrp: 550,
      category: 'Fertilizers',
      packSize: '1 kg',
      isBestSeller: true,
      variants: [
        ProductVariant(id: 'v2_1', label: '500 gm', displayRate: 230, printedMrp: 300),
        ProductVariant(id: 'v2_2', label: '1 kg', displayRate: 420, printedMrp: 550),
        ProductVariant(id: 'v2_3', label: '4 kg', displayRate: 1550, printedMrp: 2100),
      ],
    ),
    ProductItem(
      id: 'PROD-003',
      title: 'Bayer Confidor Super Powerful Systemic Insecticide',
      technicalName: 'Imidacloprid 30.5% SC',
      vendor: 'Bayer CropScience',
      imageUrl: 'https://dujjhct8zer0r.cloudfront.net/images/prod_image/bayer-confidor.webp',
      displayRate: 1450,
      printedMrp: 1800,
      category: 'Insecticides',
      packSize: '500 ml',
      isBestSeller: true,
      variants: [
        ProductVariant(id: 'v3_1', label: '100 ml', displayRate: 350, printedMrp: 440),
        ProductVariant(id: 'v3_2', label: '250 ml', displayRate: 780, printedMrp: 970),
        ProductVariant(id: 'v3_3', label: '500 ml', displayRate: 1450, printedMrp: 1800),
        ProductVariant(id: 'v3_4', label: '1 Ltr', displayRate: 2750, printedMrp: 3450),
      ],
    ),
    ProductItem(
      id: 'PROD-004',
      title: 'Syngenta Ridomil Gold Broad Spectrum Fungicide',
      technicalName: 'Metalaxyl-M 4% + Mancozeb 64% WP',
      vendor: 'Syngenta Agro',
      imageUrl: 'https://dujjhct8zer0r.cloudfront.net/images/prod_image/ridomil-gold.webp',
      displayRate: 640,
      printedMrp: 820,
      category: 'Fungicides',
      packSize: '500 g',
      isBestSeller: true,
      variants: [
        ProductVariant(id: 'v4_1', label: '250 gm', displayRate: 350, printedMrp: 450),
        ProductVariant(id: 'v4_2', label: '500 gm', displayRate: 640, printedMrp: 820),
        ProductVariant(id: 'v4_3', label: '1 kg', displayRate: 1220, printedMrp: 1580),
      ],
    ),
    ProductItem(
      id: 'PROD-005',
      title: 'UPL Saaf Contact and Systemic Fungicide',
      technicalName: 'Carbendazim 12% + Mancozeb 63% WP',
      vendor: 'UPL Limited',
      imageUrl: 'https://dujjhct8zer0r.cloudfront.net/images/prod_image/upl-saaf.webp',
      displayRate: 310,
      printedMrp: 450,
      category: 'Fungicides',
      packSize: '250 g',
      isBestSeller: true,
      variants: [
        ProductVariant(id: 'v5_1', label: '100 gm', displayRate: 140, printedMrp: 190),
        ProductVariant(id: 'v5_2', label: '250 gm', displayRate: 310, printedMrp: 450),
        ProductVariant(id: 'v5_3', label: '500 gm', displayRate: 590, printedMrp: 820),
        ProductVariant(id: 'v5_4', label: '1 kg', displayRate: 1100, printedMrp: 1550),
      ],
    ),
    ProductItem(
      id: 'PROD-006',
      title: 'Mahyco Hybrid Tomato Seeds High Yield',
      technicalName: 'Abhinav Hybrid Tomato Seeds',
      vendor: 'Mahyco Seeds',
      imageUrl: 'https://dujjhct8zer0r.cloudfront.net/images/prod_image/mahyco-tomato.webp',
      displayRate: 980,
      printedMrp: 1250,
      category: 'Seeds',
      packSize: '10 g (3500 seeds)',
      isBestSeller: true,
      variants: [
        ProductVariant(id: 'v6_1', label: '10 gm x 1 Qty', displayRate: 980, printedMrp: 1250),
        ProductVariant(id: 'v6_2', label: '10 gm x 2 Qty', displayRate: 1890, printedMrp: 2500),
        ProductVariant(id: 'v6_3', label: '10 gm x 5 Qty', displayRate: 4600, printedMrp: 6250),
      ],
    ),
    ProductItem(
      id: 'PROD-007',
      title: 'Neptune 16L Battery Operated Agricultural Sprayer',
      technicalName: 'Knapsack Battery Sprayer 12V 8Ah',
      vendor: 'Neptune Farming',
      imageUrl: 'https://dujjhct8zer0r.cloudfront.net/images/prod_image/neptune-sprayer.webp',
      displayRate: 2399,
      printedMrp: 3500,
      category: 'Equipments',
      packSize: '1 Piece',
      isBestSeller: true,
      variants: [
        ProductVariant(id: 'v7_1', label: '16 Litre Std', displayRate: 2399, printedMrp: 3500),
        ProductVariant(id: 'v7_2', label: '16L + Extra Lance', displayRate: 2699, printedMrp: 3950),
      ],
    ),
    ProductItem(
      id: 'PROD-008',
      title: 'Dhanuka Targa Super Post-Emergence Herbicide',
      technicalName: 'Quizalofop Ethyl 5% EC',
      vendor: 'Dhanuka Agritech',
      imageUrl: 'https://dujjhct8zer0r.cloudfront.net/images/prod_image/targa-super.webp',
      displayRate: 720,
      printedMrp: 950,
      category: 'Herbicides',
      packSize: '500 ml',
      isBestSeller: true,
      variants: [
        ProductVariant(id: 'v8_1', label: '250 ml', displayRate: 390, printedMrp: 510),
        ProductVariant(id: 'v8_2', label: '500 ml', displayRate: 720, printedMrp: 950),
        ProductVariant(id: 'v8_3', label: '1 Ltr', displayRate: 1380, printedMrp: 1820),
      ],
    ),
    ProductItem(
      id: 'PROD-009',
      title: 'IFFCO Nano Urea Liquid Fertilizer',
      technicalName: 'Nano Nitrogen 4% w/v',
      vendor: 'IFFCO',
      imageUrl: 'https://dujjhct8zer0r.cloudfront.net/images/prod_image/iffco-nano.webp',
      displayRate: 225,
      printedMrp: 240,
      category: 'Fertilizers',
      packSize: '500 ml',
      isBestSeller: false,
      variants: [
        ProductVariant(id: 'v9_1', label: '500 ml', displayRate: 225, printedMrp: 240),
        ProductVariant(id: 'v9_2', label: '500 ml x 2 Qty', displayRate: 440, printedMrp: 480),
      ],
    ),
    ProductItem(
      id: 'PROD-010',
      title: 'Tata Rallis Tafgor Systemic Insecticide',
      technicalName: 'Dimethoate 30% EC',
      vendor: 'Rallis India Ltd',
      imageUrl: 'https://dujjhct8zer0r.cloudfront.net/images/prod_image/tafgor.webp',
      displayRate: 340,
      printedMrp: 420,
      category: 'Insecticides',
      packSize: '250 ml',
      isBestSeller: false,
      variants: [
        ProductVariant(id: 'v10_1', label: '100 ml', displayRate: 155, printedMrp: 190),
        ProductVariant(id: 'v10_2', label: '250 ml', displayRate: 340, printedMrp: 420),
        ProductVariant(id: 'v10_3', label: '500 ml', displayRate: 640, printedMrp: 790),
      ],
    ),
    ProductItem(
      id: 'PROD-011',
      title: 'Bayer Nativo Premium Broad-Spectrum Fungicide',
      technicalName: 'Tebuconazole 50% + Trifloxystrobin 25% WG',
      vendor: 'Bayer CropScience',
      imageUrl: 'https://dujjhct8zer0r.cloudfront.net/images/prod_image/bayer-nativo.webp',
      displayRate: 1150,
      printedMrp: 1450,
      category: 'Fungicides',
      packSize: '100 g',
      isBestSeller: false,
      variants: [
        ProductVariant(id: 'v11_1', label: '100 gm', displayRate: 1150, printedMrp: 1450),
        ProductVariant(id: 'v11_2', label: '250 gm', displayRate: 2750, printedMrp: 3400),
      ],
    ),
    ProductItem(
      id: 'PROD-012',
      title: 'Seminis Ananya Hybrid Chilli Seeds High Pungency',
      technicalName: 'Hot Pepper Ananya Hybrid Seeds',
      vendor: 'Seminis Vegetable Seeds',
      imageUrl: 'https://dujjhct8zer0r.cloudfront.net/images/prod_image/seminis-chilli.webp',
      displayRate: 680,
      printedMrp: 850,
      category: 'Seeds',
      packSize: '10 g (1500 seeds)',
      isBestSeller: false,
      variants: [
        ProductVariant(id: 'v12_1', label: '10 gm x 1 Qty', displayRate: 680, printedMrp: 850),
        ProductVariant(id: 'v12_2', label: '10 gm x 2 Qty', displayRate: 1320, printedMrp: 1700),
      ],
    ),
  ];
}

class CategoryItem {
  final String id;
  final String name;
  final String icon;
  final List<String> subcategories;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    this.subcategories = const [],
  });

  static List<CategoryItem> get sampleCategories => const [
    CategoryItem(
      id: 'seeds',
      name: 'Seeds',
      icon: '🌱',
      subcategories: [
        'Hybrid Vegetable Seeds',
        'Field Crop Seeds',
        'Flower & Kitchen Garden Seeds',
        'Forage & Green Manure',
      ],
    ),
    CategoryItem(
      id: 'insecticides',
      name: 'Insecticides',
      icon: '🦗',
      subcategories: [
        'Bio-Insecticides',
        'Systemic Insecticides',
        'Caterpillar & Bollworm Control',
        'Sucking Pest & Thrips Control',
      ],
    ),
    CategoryItem(
      id: 'fungicides',
      name: 'Fungicides',
      icon: '🍄',
      subcategories: [
        'Contact Fungicides',
        'Systemic Fungicides',
        'Bio-Fungicides & Trichoderma',
        'Downy & Powdery Mildew Care',
      ],
    ),
    CategoryItem(
      id: 'fertilizers',
      name: 'Fertilizers & Nutrients',
      icon: '🧪',
      subcategories: [
        'Water Soluble NPK (19:19:19 / 0:52:34)',
        'Chelated Micronutrients (Zinc, Boron)',
        'Bio-fertilizers & Soil Conditioners',
        'Organic Manure & Humic Acid',
      ],
    ),
    CategoryItem(
      id: 'herbicides',
      name: 'Herbicides',
      icon: '🌿',
      subcategories: [
        'Pre-Emergent Herbicides',
        'Post-Emergent Herbicides',
        'Selective Weedicides',
        'Total Weed Killers',
      ],
    ),
    CategoryItem(
      id: 'equipment',
      name: 'Farm Equipment',
      icon: '🚜',
      subcategories: [
        'Battery Operated Sprayers (16L/18L)',
        'Manual & Knapsack Sprayers',
        'Brush Cutters & Power Weeders',
        'Pruning Tools & Farm Safety Kits',
      ],
    ),
    CategoryItem(
      id: 'irrigation',
      name: 'Drip & Irrigation',
      icon: '💧',
      subcategories: [
        'Drip Lateral Pipes & Drippers',
        'Rain Hose & Sprinkler Nozzles',
        'Venturi Injectors & Screen Filters',
        'Fittings & Joiners',
      ],
    ),
    CategoryItem(
      id: 'gardening',
      name: 'Home Gardening',
      icon: '🏡',
      subcategories: [
        'Enriched Potting Soil & Cocopeat',
        'Plant Boosters & Flowering Spray',
        'Hand Sprayers & Pruning Shears',
        'Indoor & Balcony Plant Care',
      ],
    ),
  ];
}

