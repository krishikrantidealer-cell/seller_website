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

class CategoryGroup {
  final String name;
  final String? icon;
  final List<String> subcategories;

  const CategoryGroup({
    required this.name,
    this.icon,
    required this.subcategories,
  });
}

class CategoryItem {
  final String id;
  final String name;
  final String icon;
  final List<CategoryGroup> groups;
  final List<String> _legacySubcategories;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    this.groups = const [],
    List<String> subcategories = const [],
  }) : _legacySubcategories = subcategories;

  List<String> get subcategories {
    if (groups.isNotEmpty) {
      return groups.expand((g) => g.subcategories).toList();
    }
    return _legacySubcategories;
  }

    static List<CategoryItem> get sampleCategories => const [
    CategoryItem(
      id: 'crop-protection',
      name: 'Crop Protection',
      icon: '🛡️',
      groups: [
        CategoryGroup(
          name: 'Insecticides',
          icon: '🦗',
          subcategories: [
            'Systemic Insecticides',
            'Contact & Ingestion',
            'Bio & Organic Insecticides',
            'Combination Insecticides',
            'Target Pest Specialists',
            'Thiamethoxam SC/WG',
            'Emamectin Benzoate 5% SG',
          ],
        ),
        CategoryGroup(
          name: 'Fungicides',
          icon: '🍄',
          subcategories: [
            'Systemic Fungicides',
            'Contact & Protective',
            'Bio-Fungicides & Biocontrol',
            'Azoxystrobin + Difenoconazole',
            'Hexaconazole 5% SC/EC',
          ],
        ),
        CategoryGroup(
          name: 'Herbicides',
          icon: '🌿',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Bio Pesticides',
          icon: '🍃',
          subcategories: [
            'Bio Insecticide',
            'Bio Fungicide',
            'Bio Miticide',
            'Beauveria Bassiana Bio-Fungus',
            'Trichoderma Viride / Harzianum',
            'Other Bio-Pesticides',
          ],
        ),
        CategoryGroup(
          name: 'Nematicide',
          icon: '🔬',
          subcategories: [
            'Plant Parasitic Nematode Control',
          ],
        ),
        CategoryGroup(
          name: 'Acaricide | Miticide',
          icon: '🔬',
          subcategories: [
            'Acaricide & Red Mite Care',
          ],
        ),
        CategoryGroup(
          name: 'Bactericides',
          icon: '🧪',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Adjuvants And Surfactants',
          icon: '💧',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Animal Repellent',
          icon: '🦌',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Combo Product',
          icon: '🏷️',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Organic Floor Cleaner',
          icon: '🍃',
          subcategories: [
          ],
        ),
      ],
    ),
    CategoryItem(
      id: 'crop-nutrition',
      name: 'Crop Nutrition',
      icon: '🧪',
      groups: [
        CategoryGroup(
          name: 'Plant Growth Regulators',
          icon: '⚡',
          subcategories: [
            'Brassinolide Growth Promoter',
            'Other Plant Growth Regulators',
          ],
        ),
        CategoryGroup(
          name: 'Humic Acid',
          icon: '🍂',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Yield Booster',
          icon: '⚡',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Fruit Quality Enhancer',
          icon: '🍉',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Flowering Stimulants',
          icon: '⚡',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Humic & Fulvic Acid',
          icon: '🍂',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Crop Special',
          icon: '🌿',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'pH Balancer',
          icon: '🌿',
          subcategories: [
          ],
        ),
      ],
    ),
    CategoryItem(
      id: 'seeds',
      name: 'Seeds',
      icon: '🌱',
      groups: [
        CategoryGroup(
          name: 'Vegetable Seeds',
          icon: '🌱',
          subcategories: [
            'Tomato Seeds',
            'Chilli Seeds',
            'Okra Seeds',
            'Brinjal Seeds',
            'Cabbage Seeds',
            'Cauliflower Seeds',
            'Bottle Gourd Seeds',
            'Bitter Gourd Seeds',
            'Cucumber Seeds',
            'Capsicum Seeds',
            'Pumpkin Seeds',
            'Ridge Gourd Seeds',
            'Sponge Gourd Seeds',
            'Snake Gourd Seeds',
            'Ash Gourd Seeds',
            'Tinda Seeds',
          ],
        ),
        CategoryGroup(
          name: 'Field Crop Seeds',
          icon: '🌱',
          subcategories: [
            'FODDER',
            'Oil Crops',
            'Cereal Crops',
          ],
        ),
        CategoryGroup(
          name: 'Fruit Seeds',
          icon: '🌱',
          subcategories: [
            'Watermelon Seeds',
            'Muskmelon Seeds',
            'Butternut Squash Seeds',
            'Papaya Seeds',
          ],
        ),
        CategoryGroup(
          name: 'Leafy Vegetable Seeds',
          icon: '🌱',
          subcategories: [
            'Amaranthus Seeds',
            'Parsely Seeds',
            'Coriander Seeds',
            'Pak Choi Seeds',
            'Swiss Chard Seeds',
            'Celery Seeds',
            'Arugula Seeds',
            'Spinach Seeds',
            'Kale Seeds',
          ],
        ),
        CategoryGroup(
          name: 'Exotic Vegetable Seeds',
          icon: '🌱',
          subcategories: [
            'Lettuce Seeds',
            'Broccoli Seeds',
            'Knol Khol Seeds',
            'Zucchini Seeds',
          ],
        ),
        CategoryGroup(
          name: 'Root Vegetable Seeds',
          icon: '🌱',
          subcategories: [
            'Radish Seeds',
            'Carrot Seeds',
            'Beetroot Seeds',
            'Turnip Seeds',
          ],
        ),
        CategoryGroup(
          name: 'Cotton Seeds',
          icon: '🌱',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Pulse Seeds',
          icon: '🌱',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Onion Seeds',
          icon: '🌱',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Marigold Seeds',
          icon: '🌱',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Desi Seeds',
          icon: '🌱',
          subcategories: [
            'Bakul Tree Seeds',
            'Agathi Seeds',
            'Fig Seeds',
            'Moringa Tree Seeds',
            'Peacock Flower Seeds',
            'Babul Seeds',
            'Custard Apple',
            'Avenue Tree Seeds',
            'Sandalwood Seeds',
            'Harad Seeds',
            'Malabar Neem Seeds',
            'Gulmohar Seeds',
            'Sagwan Seeds',
            'Mahogany Seeds',
            'Sheesham Seeds',
            'Karanj Seeds',
            'Terminalia Arjuna Seeds',
            'Bamboo Seeds',
            'Siris Seeds',
            'Lemon Seeds',
            'Tulsi Seeds',
            'Rain Tree Seeds',
            'Subabul Seeds',
            'Fodder',
            'Eucalyptus Seeds',
            'Baheda Seeds',
            'Guava Seeds',
            'Anjan Tree Seeds',
          ],
        ),
        CategoryGroup(
          name: 'Mushroom Seeds',
          icon: '🌱',
          subcategories: [
            'Ready To Fruit',
            'Mushroom Fertilizer',
            'Mushroom Spawn',
            'Mushroom Culture',
            'Oyster Mushroom',
            'Mushroom Dowels',
          ],
        ),
        CategoryGroup(
          name: 'Seeds Ball',
          icon: '🌱',
          subcategories: [
          ],
        ),
      ],
    ),
    CategoryItem(
      id: 'fertilizers',
      name: 'Fertilizers',
      icon: '🌾',
      groups: [
        CategoryGroup(
          name: 'Water Soluble Fertilizers',
          icon: '🌾',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Bio Fertilizers',
          icon: '🌾',
          subcategories: [
            'Mycorrhiza Bio-Fertilizer (VAM)',
            'Rhizobium Legume Inoculant',
            'Azotobacter Nitrogen Fixer',
            'Phosphate Solubilizing Bacteria (PSB)',
            'Other Bio-Fertilizers',
          ],
        ),
        CategoryGroup(
          name: 'Liquid Fertilizers',
          icon: '🌾',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Chelated Micronutrient Fertilizer',
          icon: '🌾',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Micronutrients Fertilizers',
          icon: '🌾',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Bulk Fertilizer',
          icon: '🌾',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Root Fertility Booster',
          icon: '⚡',
          subcategories: [
          ],
        ),
      ],
    ),
    CategoryItem(
      id: 'equipments',
      name: 'Equipments',
      icon: '🚜',
      groups: [
        CategoryGroup(
          name: 'Spray Pump',
          icon: '🔋',
          subcategories: [
            'Manual Sprayer',
            'Portable Power Sprayer',
            'Double Motor Battery Sprayer',
            'Pressure Washers',
            '2 in 1 Battery Sprayer',
            'Power Sprayer',
            'Foot & Rocker Sprayer',
            'Mist Blower Sprayers',
            'Battery Operated Sprayer',
            'Sprayer Parts & Accessories',
            'Tractor Mounted Sprayers',
          ],
        ),
        CategoryGroup(
          name: 'Agriculture Hand Tools',
          icon: '🔧',
          subcategories: [
            'Fruit Picker',
            'Weed Remover Tools',
            'Milking Machine',
            'Manual Seeder Machine',
            'Other Tools',
            'Manual Plant Transplanter',
            'Wheel hoe',
            'Pressure Washer Pipe',
          ],
        ),
        CategoryGroup(
          name: 'Agricultural Hardware',
          icon: '⚙️',
          subcategories: [
            'Tiller Attachment',
            'Brush Cutter Attachments',
            'Tufrope',
            'Jatka Machine',
            'Cable Wire',
            'Seedling Tray',
          ],
        ),
        CategoryGroup(
          name: 'Traps',
          icon: '🪤',
          subcategories: [
            'Mosquito Killer Machine',
            'Solar Trap',
            'Traps And Lures',
            'Sticky Traps',
            'Animal Repellent Devices',
          ],
        ),
        CategoryGroup(
          name: 'Weeders',
          icon: '🌿',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Brush Cutter',
          icon: '✂️',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Chaff Cutter',
          icon: '✂️',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Water Pump',
          icon: '🔋',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Earth Auger',
          icon: '⚙️',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Chain Saw',
          icon: '✂️',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Crop Cover',
          icon: '🛡️',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Tarpaulin',
          icon: '🛡️',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Mulching Paper',
          icon: '🛡️',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Solar Agriculture Products',
          icon: '☀️',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Biofloc Tarpaulin',
          icon: '🛡️',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Vermicompost Bed',
          icon: '🪱',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Azolla Bed',
          icon: '🌿',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Pond Liner',
          icon: '💧',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Hedge Trimmer',
          icon: '✂️',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Weed Mat',
          icon: '🌿',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Soil Testing Tools',
          icon: '🔧',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Torch Light',
          icon: '🌿',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Fogging Machine',
          icon: '🌿',
          subcategories: [
          ],
        ),
      ],
    ),
    CategoryItem(
      id: 'irrigation',
      name: 'Irrigation',
      icon: '💧',
      groups: [
        CategoryGroup(
          name: 'Rain Pipe',
          icon: '💧',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Drip Irrigation Accessories',
          icon: '💧',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Pipe & Fitting',
          icon: '💧',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Drip Irrigation Kit',
          icon: '💧',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Sprinkler',
          icon: '💧',
          subcategories: [
          ],
        ),
      ],
    ),
    CategoryItem(
      id: 'gardening',
      name: 'Gardening',
      icon: '🏡',
      groups: [
        CategoryGroup(
          name: 'Grow Bag',
          icon: '🪴',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Gardening Kit',
          icon: '🪴',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Coco Peat',
          icon: '🪴',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Pesticides',
          icon: '🌿',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Waste Compost Management',
          icon: '♻️',
          subcategories: [
            'Bokashi Bin',
          ],
        ),
        CategoryGroup(
          name: 'Spray Pumps',
          icon: '🔋',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Accessories',
          icon: '🌿',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Lawn Mowers',
          icon: '🌿',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Seeds',
          icon: '🌱',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'FLOWER SEEDS',
          icon: '🌱',
          subcategories: [
            'Gomphrena',
            'Celosia',
            'Chrysanthemum',
            'Balsam',
            'Calendula',
            'Dahlia',
            'Vinca',
            'Zinnia',
            'Yellow Flower',
            'Cosmos',
          ],
        ),
        CategoryGroup(
          name: 'Garden Shade Net',
          icon: '🛡️',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Fertilizer',
          icon: '🌾',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Transplanting/ Repotting Mat',
          icon: '🪴',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Tools',
          icon: '🔧',
          subcategories: [
            'Weed Extractor',
            'Khurpa',
            'Garden Tool Kit',
            'Pond Skimming Net',
            'Secateurs',
            'Weeding Trowel',
            'Spade (Favada)',
            'Pruning Saw',
            'Telescopic Handle',
            'Scuffle Hoe',
            'Trowel',
            'Other Gardening Tools',
            'Soil Rake (Panja)',
            'Shears',
            'Loppers',
            'Leaf Rake',
          ],
        ),
        CategoryGroup(
          name: 'Pebbles',
          icon: '🪨',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Fertilizer Blend',
          icon: '🌾',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'De Oiled Cake',
          icon: '🌿',
          subcategories: [
          ],
        ),
      ],
    ),
    CategoryItem(
      id: 'organic-farming',
      name: 'Organic Farming',
      icon: '🍃',
      groups: [
        CategoryGroup(
          name: 'Organic Remedial Inputs',
          icon: '🍃',
          subcategories: [
            'Organic Fungicides',
            'Organic Pesticides',
          ],
        ),
        CategoryGroup(
          name: 'Vermi Compost',
          icon: '🪱',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Neem Oil',
          icon: '🍃',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Waste Decomposer',
          icon: '♻️',
          subcategories: [
            'National Centre Waste Decomposer',
          ],
        ),
        CategoryGroup(
          name: 'Viricides',
          icon: '🧪',
          subcategories: [
          ],
        ),
      ],
    ),
    CategoryItem(
      id: 'cattle-and-bird-care',
      name: 'Cattle & Bird Care',
      icon: '🐄',
      groups: [
        CategoryGroup(
          name: 'Poultry Feed Supplements',
          icon: '🐔',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Goat And Sheep Care',
          icon: '🐐',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Aqua Care',
          icon: '🐟',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Mosquito Net',
          icon: '🛡️',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Fodder Seed',
          icon: '🌱',
          subcategories: [
            'Forages',
            'Sorghum',
            'Alfalfa',
            'Gliricidia',
            'Hedge Lucerne',
            'Multi Cut Grass',
            'Napier',
            'Barseem',
            'Punjabi Grass',
          ],
        ),
        CategoryGroup(
          name: 'Animal Feed Supplements',
          icon: '🐄',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Mineral Mixture',
          icon: '💊',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Swine Supplement',
          icon: '🐄',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Aquaculture Feed Additives',
          icon: '🐟',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Bird Food',
          icon: '🐔',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Silage Bag (Murghas Bag)',
          icon: '🌿',
          subcategories: [
          ],
        ),
      ],
    ),
    CategoryItem(
      id: 'bulk',
      name: 'Bulk',
      icon: '📦',
      groups: [
        CategoryGroup(
          name: 'Remedies',
          icon: '💊',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Seeds',
          icon: '🌱',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Organic Products',
          icon: '🌿',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Irrigation Parts',
          icon: '💧',
          subcategories: [
          ],
        ),
        CategoryGroup(
          name: 'Fertilizers',
          icon: '🌾',
          subcategories: [
          ],
        ),
      ],
    ),
    CategoryItem(
      id: 'har-din-sasta',
      name: 'Har Din Sasta',
      icon: '🏷️',
    ),
  ];
}

class TechnicalItem {
  final String name;
  final String category;
  final String description;
  final List<String> targetedPestsOrCrops;
  final String formulationType;

  const TechnicalItem({
    required this.name,
    required this.category,
    this.description = '',
    this.targetedPestsOrCrops = const [],
    this.formulationType = '',
  });

  String get firstLetter {
    if (name.isEmpty) return '#';
    final char = name[0].toUpperCase();
    if (RegExp(r'[A-Z]').hasMatch(char)) return char;
    return '#';
  }

  static const List<TechnicalItem> sampleTechnicalItems = [
    // A
    TechnicalItem(
      name: 'Abamectin 1.9% EC',
      category: 'Insecticide',
      description: 'Fermentation-derived miticide and insecticide for red spider mites, two-spotted mites, and leafminers.',
      targetedPestsOrCrops: ['Red Spider Mites', 'Two-spotted Mite', 'Leafminer in vegetables'],
      formulationType: 'EC',
    ),
    TechnicalItem(
      name: 'Abhinav Hybrid Tomato Seeds',
      category: 'Seeds',
      description: 'Determinate high-yielding tomato hybrid with strong TYLCV and bacterial wilt tolerance.',
      targetedPestsOrCrops: ['Tomato commercial cultivation', 'Bacterial wilt resistance'],
      formulationType: 'Seed',
    ),
    TechnicalItem(
      name: 'Acephate 75% SP',
      category: 'Insecticide',
      description: 'Systemic organophosphate insecticide effective against jassids, aphids, and bollworms in cotton and vegetables.',
      targetedPestsOrCrops: ['Aphids', 'Jassids', 'Cotton Bollworm'],
      formulationType: 'SP',
    ),
    TechnicalItem(
      name: 'Acetamiprid 20% SP',
      category: 'Insecticide',
      description: 'Neonicotinoid insecticide with quick translaminar action against whiteflies, aphids, and leafhoppers.',
      targetedPestsOrCrops: ['Whitefly', 'Aphids', 'Leafhopper in chilli & cotton'],
      formulationType: 'SP',
    ),
    TechnicalItem(
      name: 'Azoxystrobin 11% + Tebuconazole 18.3% SC',
      category: 'Fungicide',
      description: 'Broad-spectrum dual action systemic fungicide preventing powdery mildew, blast, and sheath blight.',
      targetedPestsOrCrops: ['Sheath Blight', 'Powdery Mildew', 'Early Blight'],
      formulationType: 'SC',
    ),

    // B
    TechnicalItem(
      name: 'Bacillus Thuringiensis (Bt) 0.5% WP',
      category: 'Bio-Insecticide',
      description: 'Biological microbial insecticide targeting lepidopteran larvae without harming beneficial insects.',
      targetedPestsOrCrops: ['Diamondback Moth', 'Helicoverpa', 'Spodoptera'],
      formulationType: 'WP',
    ),
    TechnicalItem(
      name: 'Bispyribac Sodium 10% SC',
      category: 'Herbicide',
      description: 'Post-emergence selective herbicide for controlling major grasses, sedges, and broadleaf weeds in rice.',
      targetedPestsOrCrops: ['Barnyard Grass', 'Echinochloa', 'Cyperus in Paddy'],
      formulationType: 'SC',
    ),
    TechnicalItem(
      name: 'Buprofezin 25% SC',
      category: 'Insecticide',
      description: 'Insect growth regulator inhibiting chitin synthesis in brown planthopper (BPH) and mealybugs.',
      targetedPestsOrCrops: ['Brown Plant Hopper', 'Mealybug', 'Whitefly nymphs'],
      formulationType: 'SC',
    ),

    // C
    TechnicalItem(
      name: 'Carbendazim 12% + Mancozeb 63% WP',
      category: 'Fungicide',
      description: 'Widely trusted contact and systemic dual fungicide for seed treatment, blast, anthracnose, and tikka disease.',
      targetedPestsOrCrops: ['Paddy Blast', 'Groundnut Tikka', 'Chilli Anthracnose', 'Seed Treatment'],
      formulationType: 'WP',
    ),
    TechnicalItem(
      name: 'Carbendazim 50% WP',
      category: 'Fungicide',
      description: 'Systemic fungicide for curative and preventive management of seed-borne and soil-borne fungal pathogens.',
      targetedPestsOrCrops: ['Loose Smut', 'Collar Rot', 'Powdery Mildew'],
      formulationType: 'WP',
    ),
    TechnicalItem(
      name: 'Cartap Hydrochloride 50% SP',
      category: 'Insecticide',
      description: 'Neurotoxic insecticide providing excellent control over paddy stem borer and leaf folder.',
      targetedPestsOrCrops: ['Paddy Stem Borer', 'Leaf Folder', 'Cabbage Diamondback Moth'],
      formulationType: 'SP',
    ),
    TechnicalItem(
      name: 'Chlorantraniliprole 18.5% SC',
      category: 'Insecticide',
      description: 'Modern anthranilic diamide delivering exceptional, long-duration control of chewing pests with high safety margins.',
      targetedPestsOrCrops: ['Stem Borer', 'Fruit & Shoot Borer', 'Diamondback Moth', 'Pod Borer'],
      formulationType: 'SC',
    ),
    TechnicalItem(
      name: 'Chlorpyrifos 20% EC',
      category: 'Insecticide',
      description: 'Trusted contact insecticide for termite management in soil and control of root grubs and foliar chewing insects.',
      targetedPestsOrCrops: ['Termites', 'Root Grubs', 'Stem Borer'],
      formulationType: 'EC',
    ),
    TechnicalItem(
      name: 'Chlorpyrifos 50% + Cypermethrin 5% EC',
      category: 'Insecticide',
      description: 'Synergistic combination insecticide offering rapid knockdown and deep penetrating kill against mixed pest complexes.',
      targetedPestsOrCrops: ['Bollworms', 'Spodoptera', 'Stem Borer', 'Sucking Pests'],
      formulationType: 'EC',
    ),
    TechnicalItem(
      name: 'Copper Oxychloride 50% WP',
      category: 'Fungicide',
      description: 'Broad-spectrum protective copper fungicide and bactericide preventing downy mildew, leaf spots, and canker.',
      targetedPestsOrCrops: ['Downy Mildew', 'Citrus Canker', 'Leaf Spot', 'Late Blight'],
      formulationType: 'WP',
    ),

    // D
    TechnicalItem(
      name: 'Deltamethrin 2.8% EC',
      category: 'Insecticide',
      description: 'Fast knockdown synthetic pyrethroid for bollworms, leaf folders, and sucking pests.',
      targetedPestsOrCrops: ['Cotton Bollworm', 'Leaf Folder', 'Fruit Borer'],
      formulationType: 'EC',
    ),
    TechnicalItem(
      name: 'Diafenthiuron 50% WP',
      category: 'Insecticide',
      description: 'Unique thiourea pro-insecticide that activates inside nymphs and adults for control of resistant whiteflies and mites.',
      targetedPestsOrCrops: ['Whitefly', 'Thrips', 'Two-spotted Mite in Chilli'],
      formulationType: 'WP',
    ),
    TechnicalItem(
      name: 'Dimethoate 30% EC',
      category: 'Insecticide',
      description: 'Systemic organophosphate insecticide and acaricide controlling aphids, thrips, leafminers, and spider mites.',
      targetedPestsOrCrops: ['Aphids', 'Thrips', 'Stem Borer', 'Red Spider Mites'],
      formulationType: 'EC',
    ),
    TechnicalItem(
      name: 'Dinotefuran 20% SG',
      category: 'Insecticide',
      description: 'Third-generation furanicotinyl systemic insecticide with quick curative effect against brown plant hoppers in paddy.',
      targetedPestsOrCrops: ['Brown Plant Hopper (BPH)', 'Whitebacked Plant Hopper'],
      formulationType: 'SG',
    ),

    // E
    TechnicalItem(
      name: 'Emamectin Benzoate 5% SG',
      category: 'Insecticide',
      description: 'Naturally derived avermectin insecticide for superior stomach-action control of caterpillars and bollworms.',
      targetedPestsOrCrops: ['Fall Armyworm', 'Bollworm', 'Pod Borer', 'Diamondback Moth'],
      formulationType: 'SG',
    ),
    TechnicalItem(
      name: 'Ethion 50% EC',
      category: 'Insecticide',
      description: 'Organophosphate insecticide and miticide controlling red spider mites, scale insects, and tea mosquitoes.',
      targetedPestsOrCrops: ['Tea Red Spider Mite', 'Scales', 'Thrips in Chilli'],
      formulationType: 'EC',
    ),

    // F
    TechnicalItem(
      name: 'Fipronil 5% SC',
      category: 'Insecticide',
      description: 'Phenylpyrazole insecticide with contact and ingestion activity against stem borer, thrips, and aphids.',
      targetedPestsOrCrops: ['Chilli Thrips', 'Stem Borer', 'Green Leafhopper'],
      formulationType: 'SC',
    ),
    TechnicalItem(
      name: 'Flubendiamide 39.35% SC',
      category: 'Insecticide',
      description: 'Ryanodine receptor disruptor offering long-lasting prevention of lepidopteran chewing caterpillars.',
      targetedPestsOrCrops: ['Diamondback Moth', 'American Bollworm', 'Tobacco Caterpillar'],
      formulationType: 'SC',
    ),

    // G
    TechnicalItem(
      name: 'Gibberellic Acid 0.001% L',
      category: 'Bio-Stimulant',
      description: 'Naturally occurring plant growth hormone promoting cell division, fruit elongation, and higher crop yields.',
      targetedPestsOrCrops: ['Grapes elongation', 'Cotton boll retention', 'Vegetable vegetative growth'],
      formulationType: 'L',
    ),
    TechnicalItem(
      name: 'Glyphosate 41% SL',
      category: 'Herbicide',
      description: 'Non-selective systemic broad-spectrum herbicide for controlling perennial and annual grasses and broadleaf weeds.',
      targetedPestsOrCrops: ['Non-crop area weed eradication', 'Tea plantation weed management'],
      formulationType: 'SL',
    ),

    // H
    TechnicalItem(
      name: 'Hexaconazole 5% SC',
      category: 'Fungicide',
      description: 'Broad-spectrum systemic triazole fungicide controlling powdery mildew, sheath blight, and rusts.',
      targetedPestsOrCrops: ['Rice Sheath Blight', 'Mango Powdery Mildew', 'Apple Scab'],
      formulationType: 'SC',
    ),
    TechnicalItem(
      name: 'Hot Pepper Ananya Hybrid Seeds',
      category: 'Seeds',
      description: 'High-pungency dark green turning glossy red chilli hybrid with excellent virus tolerance.',
      targetedPestsOrCrops: ['Chilli production', 'High-heat Indian markets'],
      formulationType: 'Seed',
    ),

    // I
    TechnicalItem(
      name: 'Imidacloprid 17.8% SL',
      category: 'Insecticide',
      description: 'Systemic chloronicotinyl insecticide widely used for seed treatment and foliar spray against sucking pests.',
      targetedPestsOrCrops: ['Aphids', 'Jassids', 'Termites', 'Whiteflies'],
      formulationType: 'SL',
    ),
    TechnicalItem(
      name: 'Imidacloprid 30.5% SC',
      category: 'Insecticide',
      description: 'Ultra-concentrated systemic insecticide specialized for structural termite eradication and resistant sucking bugs.',
      targetedPestsOrCrops: ['Soil Subterranean Termites', 'Cotton Jassids', 'Chilli Aphids'],
      formulationType: 'SC',
    ),

    // K
    TechnicalItem(
      name: 'Kasugamycin 3% SL',
      category: 'Fungicide',
      description: 'Systemic aminoglycoside antibiotic fungicide and bactericide preventing rice blast and bacterial brown spot.',
      targetedPestsOrCrops: ['Paddy Neck Blast', 'Leaf Blast', 'Bacterial Gummosis'],
      formulationType: 'SL',
    ),
    TechnicalItem(
      name: 'Knapsack Battery Sprayer 12V 8Ah',
      category: 'Equipment',
      description: 'Heavy-duty 16-liter electric rechargeable agricultural sprayer with dual-speed motor and brass nozzles.',
      targetedPestsOrCrops: ['Crop chemical spraying', 'Orchard foliar applications'],
      formulationType: 'Tool',
    ),

    // L
    TechnicalItem(
      name: 'Lambda Cyhalothrin 4.9% CS',
      category: 'Insecticide',
      description: 'Micro-encapsulated synthetic pyrethroid giving UV-stable extended residual protection against bollworms and thrips.',
      targetedPestsOrCrops: ['Cotton BollwormComplex', 'Stem Borer', 'Fruit Borer'],
      formulationType: 'CS',
    ),
    TechnicalItem(
      name: 'Lambda Cyhalothrin 5% EC',
      category: 'Insecticide',
      description: 'Fast-action pyrethroid insecticide controlling a wide range of foliar chewing and sucking insect pests.',
      targetedPestsOrCrops: ['Thrips', 'Aphids', 'Fruit Borer', 'Leaf Folder'],
      formulationType: 'EC',
    ),

    // M
    TechnicalItem(
      name: 'Mancozeb 75% WP',
      category: 'Fungicide',
      description: 'Multisite contact dithiocarbamate fungicide for reliable prevention of late blight, early blight, and anthracnose.',
      targetedPestsOrCrops: ['Potato Late Blight', 'Tomato Early Blight', 'Apple Scab', 'Grape Downy Mildew'],
      formulationType: 'WP',
    ),
    TechnicalItem(
      name: 'Metalaxyl-M 4% + Mancozeb 64% WP',
      category: 'Fungicide',
      description: 'Superior systemic-contact combination delivering both curative inside-tissue action and outer spore protection.',
      targetedPestsOrCrops: ['Late Blight in Potato/Tomato', 'Downy Mildew in Grapes & Cucurbits', 'Damping Off'],
      formulationType: 'WP',
    ),
    TechnicalItem(
      name: 'Metribuzin 70% WP',
      category: 'Herbicide',
      description: 'Selective pre and early post-emergence herbicide for sugarcane, potato, soybean, and wheat fields.',
      targetedPestsOrCrops: ['Phalaris minor', 'Chenopodium', 'Echinochloa'],
      formulationType: 'WP',
    ),
    TechnicalItem(
      name: 'Mycorrhiza Bio Fertilizer VAM',
      category: 'Bio Fertilizer',
      description: 'Vesicular-Arbuscular Mycorrhizal bio-inoculant expanding root absorptive surface for phosphorus and moisture uptake.',
      targetedPestsOrCrops: ['Root expansion', 'Drought tolerance', 'Phosphorus mobilization'],
      formulationType: 'Granule/Powder',
    ),

    // N
    TechnicalItem(
      name: 'Nano Nitrogen 4% w/v',
      category: 'Fertilizer',
      description: 'Engineered bio-available nano-scale liquid nitrogen for rapid foliar uptake, reducing chemical urea leaching.',
      targetedPestsOrCrops: ['Cereal crops', 'Vegetative greening', 'Photosynthetic boost'],
      formulationType: 'Liquid',
    ),
    TechnicalItem(
      name: 'Neem Oil (Azadirachtin 10000 PPM)',
      category: 'Bio-Insecticide',
      description: 'Organic cold-pressed pure neem extract acting as an anti-feedant, repellent, and insect growth inhibitor.',
      targetedPestsOrCrops: ['Whiteflies', 'Mealybugs', 'Leafminers', 'Mites across organic farms'],
      formulationType: 'EC',
    ),

    // P
    TechnicalItem(
      name: 'Paclobutrazol 23% SC',
      category: 'Plant Growth Regulator',
      description: 'Triazole plant growth regulator that curbs excessive vegetative shoots to trigger uniform flowering in mango.',
      targetedPestsOrCrops: ['Mango flowering synchronization', 'Canopy size regulation'],
      formulationType: 'SC',
    ),
    TechnicalItem(
      name: 'Pendimethalin 30% EC',
      category: 'Herbicide',
      description: 'Pre-emergence dinitroaniline herbicide inhibiting root and shoot growth in germinating annual weed seeds.',
      targetedPestsOrCrops: ['Annual grasses', 'Broadleaf weeds in Soybean, Cotton, Onion & Garlic'],
      formulationType: 'EC',
    ),
    TechnicalItem(
      name: 'Pretilachlor 50% EC',
      category: 'Herbicide',
      description: 'Selective pre-emergence herbicide for transplanted paddy, controlling grasses, sedges, and broadleaved weeds.',
      targetedPestsOrCrops: ['Echinochloa crusgalli', 'Cyperus difformis in Rice'],
      formulationType: 'EC',
    ),
    TechnicalItem(
      name: 'Propiconazole 25% EC',
      category: 'Fungicide',
      description: 'Systemic triazole fungicide with protective, curative, and eradicative properties against leaf rust and karnal bunt.',
      targetedPestsOrCrops: ['Wheat Yellow & Brown Rust', 'Karnal Bunt', 'Rice Sheath Blight'],
      formulationType: 'EC',
    ),

    // Q
    TechnicalItem(
      name: 'Quizalofop Ethyl 5% EC',
      category: 'Herbicide',
      description: 'Selective systemic post-emergence herbicide controlling narrow-leaf grassy weeds in broadleaf crops.',
      targetedPestsOrCrops: ['Echinochloa', 'Dactyloctenium', 'Digitaria in Soybean, Groundnut & Cotton'],
      formulationType: 'EC',
    ),

    // S
    TechnicalItem(
      name: 'Spiromesifen 22.9% SC',
      category: 'Insecticide',
      description: 'Lipid biosynthesis inhibitor specialized against whiteflies, red spider mites, and yellow mites.',
      targetedPestsOrCrops: ['Chilli Yellow Mites', 'Brinjal Red Spider Mites', 'Whitefly nymphs'],
      formulationType: 'SC',
    ),
    TechnicalItem(
      name: 'Sulfur 80% WDG',
      category: 'Fungicide',
      description: 'Dual-action contact fungicide, acaricide, and essential secondary plant nutrient in water-dispersible granules.',
      targetedPestsOrCrops: ['Powdery Mildew in Grapes/Mango', 'Rust', 'Sulphur deficiency in pulses'],
      formulationType: 'WDG',
    ),

    // T
    TechnicalItem(
      name: 'Tebuconazole 25.9% EC',
      category: 'Fungicide',
      description: 'Systemic broad-spectrum ergosterol inhibitor fungicide for blast, sheath blight, and leaf spot control.',
      targetedPestsOrCrops: ['Paddy Sheath Blight', 'Groundnut Tikka', 'Chilli Fruit Rot'],
      formulationType: 'EC',
    ),
    TechnicalItem(
      name: 'Tebuconazole 50% + Trifloxystrobin 25% WG',
      category: 'Fungicide',
      description: 'Premier combination of triazole and strobilurin delivering superior mesostemic protection with plant greening benefits.',
      targetedPestsOrCrops: ['Sheath Blight', 'Paddy Blast', 'Powdery Mildew in Grapes', 'Anthracnose'],
      formulationType: 'WG',
    ),
    TechnicalItem(
      name: 'Thiamethoxam 25% WG',
      category: 'Insecticide',
      description: 'Second-generation neonicotinoid with fast translaminar uptake for rapid management of sucking insect vectors.',
      targetedPestsOrCrops: ['Aphids', 'Jassids', 'Whiteflies', 'Paddy Stem Borer', 'Thrips'],
      formulationType: 'WG',
    ),
    TechnicalItem(
      name: 'Thiophanate Methyl 70% WP',
      category: 'Fungicide',
      description: 'Broad-spectrum systemic curative fungicide for control of anthracnose, powdery mildew, scab, and fusarium wilt.',
      targetedPestsOrCrops: ['Anthracnose', 'Fusarium Wilt', 'Apple Scab', 'Brown Rust'],
      formulationType: 'WP',
    ),
    TechnicalItem(
      name: 'Trichoderma Viride 1% WP',
      category: 'Bio-Fungicide',
      description: 'Antagonistic biocontrol fungus that parasitizes soil-borne fungal pathogens causing damping off, root rot, and collar rot.',
      targetedPestsOrCrops: ['Root Rot', 'Collar Rot', 'Seedling Damping Off in nurseries'],
      formulationType: 'WP',
    ),

    // Z
    TechnicalItem(
      name: 'Zinc Solubilizing Bio-Fertilizer (ZSB)',
      category: 'Bio Fertilizer',
      description: 'Beneficial bacterial strain that converts insoluble soil zinc compounds into plant-absorbable ions.',
      targetedPestsOrCrops: ['Khaira disease in Paddy', 'Zinc deficiency correction', 'Root vigor'],
      formulationType: 'Liquid/Carrier',
    ),
    TechnicalItem(
      name: 'Zineb 75% WP',
      category: 'Fungicide',
      description: 'Protective organic contact fungicide with zinc supplementation for downy mildew, rust, and leaf spot.',
      targetedPestsOrCrops: ['Downy Mildew', 'Early Blight', 'Leaf Spots'],
      formulationType: 'WP',
    ),
  ];
}

