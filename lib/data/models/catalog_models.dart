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
  });

  int get discountPercent {
    if (printedMrp <= 0 || displayRate >= printedMrp) return 0;
    return (((printedMrp - displayRate) / printedMrp) * 100).round();
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
    ),
  ];
}

class CategoryItem {
  final String id;
  final String name;
  final String icon;

  const CategoryItem({required this.id, required this.name, required this.icon});

  static List<CategoryItem> get sampleCategories => const [
    CategoryItem(id: 'seeds', name: 'Seeds', icon: '🌱'),
    CategoryItem(id: 'insecticides', name: 'Insecticides', icon: '🦗'),
    CategoryItem(id: 'fungicides', name: 'Fungicides', icon: '🍄'),
    CategoryItem(id: 'fertilizers', name: 'Fertilizers & Nutrients', icon: '🧪'),
    CategoryItem(id: 'herbicides', name: 'Herbicides', icon: '🌿'),
    CategoryItem(id: 'equipment', name: 'Farm Equipment', icon: '🚜'),
    CategoryItem(id: 'irrigation', name: 'Drip & Irrigation', icon: '💧'),
    CategoryItem(id: 'gardening', name: 'Home Gardening', icon: '🏡'),
  ];
}
