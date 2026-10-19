import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/cart_state.dart';
import '../../data/models/catalog_models.dart';
import '../widgets/top_info_bar.dart';
import '../widgets/main_nav_header.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/product_card.dart';
import '../widgets/web_footer.dart';

class ProductDetailView extends StatefulWidget {
  final ProductItem product;

  const ProductDetailView({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _tabsScrollController = ScrollController();
  late ProductVariant _selectedVariant;
  int _selectedQuantity = 1;
  int _activeTabIndex = 0;
  int _selectedImageIndex = 0;
  final Set<int> _expandedMobileSections = {0};

  // Farmer Reviews State
  late List<FarmerReviewItem> _reviews;
  bool _isWritingReview = false;
  int _newReviewRating = 5;
  String _newReviewCrop = 'Cotton';
  String _selectedReviewFilter = 'all'; // 'all', 'media', '5star'
  String? _formValidationError;

  final TextEditingController _reviewAuthorController = TextEditingController();
  final TextEditingController _reviewRoleController = TextEditingController();
  final TextEditingController _reviewTitleController = TextEditingController();
  final TextEditingController _reviewCommentController = TextEditingController();
  final List<String> _newReviewImages = [];
  Map<String, String>? _newReviewVideo;

  double get _averageRating {
    if (_reviews.isEmpty) return 0.0;
    final total = _reviews.fold<int>(0, (sum, item) => sum + item.rating);
    return total / _reviews.length;
  }

  int get _totalReviewsCount => _reviews.length;

  @override
  void initState() {
    super.initState();
    _selectedVariant = widget.product.defaultVariant;
    _initReviews();
  }

  void _initReviews() {
    _reviews = [
      FarmerReviewItem(
        id: 'rev_1',
        authorName: 'Rajesh Patil',
        authorRole: 'Cotton Grower, Jalna (Maharashtra)',
        rating: 5,
        title: 'Outstanding pest knockdown within 48 hours',
        comment:
            'Applied on 6 acres of cotton during the peak vegetative stage when whitefly and bollworm nymphs appeared. Visible knockdown in 48 hours without causing leaf scorch or stress. Company batch authenticity QR code scanned verified genuine.',
        date: '3 days ago',
        isVerified: true,
        cropType: 'Cotton',
        imageUrls: const [
          'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=600&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=600&auto=format&fit=crop&q=80',
        ],
        videoName: 'cotton_spray_demonstration_trial.mp4',
        videoDuration: '0:38 min',
        videoSize: '14.2 MB',
        videoThumbnailUrl:
            'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=600&auto=format&fit=crop&q=80',
      ),
      FarmerReviewItem(
        id: 'rev_2',
        authorName: 'Suresh Reddy',
        authorRole: 'Chilli Farmer, Guntur (Andhra Pradesh)',
        rating: 5,
        title: 'Superior flower retention & healthy canopy',
        comment:
            'Observed high leaf shine and drastically reduced flower dropping in chilli within a week of application. Formulation purity is far better than regional distributors, plus EBS delivered right to village depot.',
        date: '1 week ago',
        isVerified: true,
        cropType: 'Chilli',
        imageUrls: const [
          'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?w=600&auto=format&fit=crop&q=80',
        ],
      ),
      FarmerReviewItem(
        id: 'rev_3',
        authorName: 'Harpreet Singh',
        authorRole: 'Paddy Grower, Karnal (Haryana)',
        rating: 5,
        title: 'Fast delivery & authentic sealed company bottle',
        comment:
            'Arrived in heavy duty tamper-proof cardboard box in 3 business days. Customer care agronomist advised accurate tank mixing instructions per 16-liter knapsack sprayer.',
        date: '2 weeks ago',
        isVerified: true,
        cropType: 'Paddy',
        imageUrls: const [],
      ),
    ];
  }

  @override
  void dispose() {
    _tabsScrollController.dispose();
    _reviewAuthorController.dispose();
    _reviewRoleController.dispose();
    _reviewTitleController.dispose();
    _reviewCommentController.dispose();
    super.dispose();
  }

  void _onVariantSelected(ProductVariant variant) {
    setState(() {
      _selectedVariant = variant;
    });
  }

  void _onAddToCart() {
    CartController.instance.addItem(widget.product, _selectedVariant, _selectedQuantity);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added $_selectedQuantity x ${widget.product.title} (${_selectedVariant.label}) to cart!',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppColors.primaryDarkGreen,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () {
            _scaffoldKey.currentState?.openEndDrawer();
          },
        ),
      ),
    );
  }

  void _onBuyNow() {
    CartController.instance.addItem(widget.product, _selectedVariant, _selectedQuantity);
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobileScreen = screenWidth < 700;

    final categoryMatches = ProductItem.sampleProducts
        .where((p) => p.id != widget.product.id && p.category.toLowerCase() == widget.product.category.toLowerCase())
        .toList();
    final otherProducts = ProductItem.sampleProducts
        .where((p) => p.id != widget.product.id && !categoryMatches.contains(p))
        .toList();
    final similarProducts = [...categoryMatches, ...otherProducts].take(6).toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF9FAFB),
      endDrawer: const QuickCartDrawer(),
      bottomNavigationBar: isMobileScreen ? _buildMobileStickyBottomBar() : null,
      body: Column(
        children: [
          // Sticky Top Navigation Header with Drop Shadow
          Container(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top utilities bar
                const TopInfoBar(),

                // Main navigation header
                AnimatedBuilder(
                  animation: CartController.instance,
                  builder: (context, _) {
                    return MainNavHeader(
                      cartItemCount: CartController.instance.totalCount,
                      onCartTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                    );
                  },
                ),
              ],
            ),
          ),

          // Scrollable Product Detail Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Breadcrumbs & Back link (Responsive)
                  _buildBreadcrumbBar(context, isMobileScreen),

            // Main Product Details Section
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1680),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobileScreen ? 12 : 24,
                    vertical: isMobileScreen ? 8 : 16,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 960;
                      final isMobile = constraints.maxWidth < 650;

                      if (isDesktop) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left: Image Viewport & Visuals
                            Expanded(
                              flex: 5,
                              child: _buildGallerySection(context, isMobile: false),
                            ),
                            const SizedBox(width: 32),
                            // Right: Product Specs, Pack Size Selector, Price, Buy Actions
                            Expanded(
                              flex: 6,
                              child: _buildPurchaseSection(context, isMobile: false),
                            ),
                          ],
                        );
                      }

                      // Mobile / Tablet stacked layout
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGallerySection(context, isMobile: isMobile),
                          const SizedBox(height: 16),
                          _buildPurchaseSection(context, isMobile: isMobile),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Tabs: Overview, Specifications & Dosage, Safety, Reviews
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1680),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobileScreen ? 12 : 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return _buildTabsSection(isMobile: constraints.maxWidth < 650);
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),

            // Similar Products Section
            if (similarProducts.isNotEmpty)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1680),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobileScreen ? 12 : 24),
                    child: _buildSimilarProductsSection(similarProducts, isMobileScreen),
                  ),
                ),
              ),

            const SizedBox(height: 48),

            // Integrated Footer with Trust Badges
            const WebFooter(),
          ],
        ),
      ),
    ),
  ],
),
);
}

  /// Sticky Bottom Bar for Mobile Viewports
  Widget _buildMobileStickyBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${_selectedVariant.displayRate.toInt()}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                  ),
                ),
                Text(
                  _selectedVariant.label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _onAddToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'Add to Cart',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _onBuyNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryCrimson,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    'Buy Now',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbBar(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1680),
          child: SizedBox(
            width: double.infinity,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back_rounded, size: 15, color: AppColors.primaryGreen),
                            const SizedBox(width: 5),
                            Text(
                              'Back',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'Home',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right_rounded, size: 15, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      widget.product.category,
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right_rounded, size: 15, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      widget.product.title,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGallerySection(BuildContext context, {required bool isMobile}) {
    final discount = _selectedVariant.discountPercent;
    final imageHeight = isMobile ? 280.0 : 420.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Display Container with white background
        Container(
          width: double.infinity,
          height: imageHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16.0 : 28.0),
                  child: Image.network(
                    widget.product.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.agriculture_rounded,
                      size: 80,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              // Discount pill
              if (discount > 0)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.discountRed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$discount% OFF',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isMobile ? 10.5 : 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              // Authentic EBS Quality Badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, size: 13, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'EBS Certified',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isMobile ? 10 : 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Thumbnail selectors
        Row(
          children: [
            for (int i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedImageIndex = i;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: isMobile ? 60 : 70,
                  height: isMobile ? 60 : 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedImageIndex == i ? AppColors.primaryGreen : AppColors.border,
                      width: _selectedImageIndex == i ? 2.0 : 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: i == 0
                      ? Image.network(
                          widget.product.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image, size: 24, color: AppColors.textMuted),
                        )
                      : Icon(
                          i == 1 ? Icons.science_rounded : Icons.eco_rounded,
                          color: _selectedImageIndex == i ? AppColors.primaryGreen : AppColors.textMuted,
                          size: 26,
                        ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 14),

        // Guarantee Strip under gallery (Responsive wrap)
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildMicroFeature(Icons.shield_outlined, '100% Genuine', isMobile),
              _buildMicroFeature(Icons.local_shipping_outlined, 'Fast Dispatch', isMobile),
              _buildMicroFeature(Icons.support_agent_outlined, 'Agronomist Help', isMobile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMicroFeature(IconData icon, String label, bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: isMobile ? 14 : 16, color: AppColors.primaryGreen),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 10.5 : 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseSection(BuildContext context, {required bool isMobile}) {
    final discount = _selectedVariant.discountPercent;
    final savings = _selectedVariant.printedMrp - _selectedVariant.displayRate;

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Pill & Vendor Tag (Responsive Wrap)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.product.category.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDarkGreen,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.storefront_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Brand: ${widget.product.vendor}',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Main Product Title
          Text(
            widget.product.title,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 17 : 21,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 6),

          // Technical Name / Active Formula
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
            decoration: BoxDecoration(
              color: AppColors.primaryCrimson.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Active Composition: ${widget.product.technicalName}',
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 11 : 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryCrimson,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Rating & Reviews row (Responsive Wrap)
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.ratingAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: AppColors.ratingAmber),
                    const SizedBox(width: 3),
                    Text(
                      _averageRating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  if (isMobile) {
                    setState(() {
                      _expandedMobileSections.add(3);
                    });
                  } else {
                    setState(() {
                      _activeTabIndex = 3;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(4),
                child: Text(
                  '$_totalReviewsCount Verified Reviews',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Text('•', style: TextStyle(color: AppColors.textMuted)),
              Text(
                '100% Quality Verified',
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: AppColors.border, height: 1),
          ),

          // PROMINENT PACK SIZE / VARIANT SELECTOR
          Text(
            'Select Pack Size / Quantity Variant:',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Variant Cards Grid (Responsive Wrap)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.product.variants.map((v) {
              final isSelected = v.id == _selectedVariant.id;
              final varDiscount = v.discountPercent;

              return InkWell(
                onTap: () => _onVariantSelected(v),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 10 : 13,
                    vertical: isMobile ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.lightGreen : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryGreen : AppColors.border,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            size: 15,
                            color: isSelected ? AppColors.primaryGreen : AppColors.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            v.label,
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 11.5 : 12.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? AppColors.primaryDarkGreen : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '₹${v.displayRate.toInt()}',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 12.5 : 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          if (v.printedMrp > v.displayRate) ...[
                            const SizedBox(width: 5),
                            Text(
                              '₹${v.printedMrp.toInt()}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppColors.textMuted,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                          if (varDiscount > 0) ...[
                            const SizedBox(width: 5),
                            Text(
                              '$varDiscount% OFF',
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.discountRed,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Price Calculation & Savings Highlight Box (Responsive Wrap)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    Text(
                      '₹${_selectedVariant.displayRate.toInt()}',
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 24 : 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    if (_selectedVariant.printedMrp > _selectedVariant.displayRate) ...[
                      Text(
                        'MRP: ₹${_selectedVariant.printedMrp.toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 12.5 : 14,
                          color: AppColors.textMuted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.discountRed.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Save ₹${savings.toInt()} ($discount% OFF)',
                          style: GoogleFonts.poppins(
                            fontSize: isMobile ? 11 : 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.discountRed,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'Inclusive of all taxes • FREE Pan-India Delivery on orders above ₹500',
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 11 : 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Stock Status & Dispatch indicator
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                'In Stock',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF065F46),
                ),
              ),
              const Text('•', style: TextStyle(color: AppColors.textMuted)),
              Text(
                'Ready to dispatch from EBS Central Hub',
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 11.5 : 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quantity Stepper + Purchase Action Buttons (Responsive Layout)
          if (isMobile) ...[
            // Mobile: Row 1 Stepper, Row 2 Dual Full-Width Action Buttons
            Row(
              children: [
                Text(
                  'Quantity:',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                _buildQuantityControl(),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _onAddToCart,
                      icon: const Icon(Icons.shopping_cart_outlined, size: 17),
                      label: Text(
                        'Add to Cart',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _onBuyNow,
                      icon: const Icon(Icons.bolt_rounded, size: 17),
                      label: Text(
                        'Buy Now',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryCrimson,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Desktop: Single horizontal row
            Row(
              children: [
                _buildQuantityControl(),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _onAddToCart,
                      icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                      label: Text(
                        'Add to Cart',
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _onBuyNow,
                      icon: const Icon(Icons.bolt_rounded, size: 18),
                      label: Text(
                        'Buy Now',
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryCrimson,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 18),

          // Agronomist consultation helpline
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.support_agent_rounded, size: 24, color: AppColors.primaryGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Need Agronomy Advisory or Dosage Guidance?',
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 11.5 : 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF166534),
                        ),
                      ),
                      Text(
                        'Speak with an EBS certified agronomist toll-free: ${AppConstants.orderCallNumber}',
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 10.5 : 11.5,
                          color: const Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_rounded, size: 16),
            color: _selectedQuantity > 1 ? AppColors.textPrimary : AppColors.textMuted,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            constraints: const BoxConstraints(),
            onPressed: _selectedQuantity > 1
                ? () {
                    setState(() {
                      _selectedQuantity--;
                    });
                  }
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$_selectedQuantity',
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 16),
            color: AppColors.textPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _selectedQuantity++;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabsSection({required bool isMobile}) {
    if (isMobile) {
      return _buildMobileAccordionSection();
    }
    return _buildDesktopTabsSection();
  }

  /// Mobile Experience: Clean, Native Expandable Accordion Panels
  Widget _buildMobileAccordionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(
                width: 3.5,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Product Information & Guidance',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 1. Overview Accordion Card (Open by default)
        _buildAccordionCard(
          index: 0,
          icon: Icons.info_outline_rounded,
          iconColor: AppColors.primaryGreen,
          title: 'Product Overview',
          subtitle: 'Formulation, purpose & key crop benefits',
          content: _buildOverviewContent(isMobile: true),
        ),

        // 2. Technical Specs Accordion Card
        _buildAccordionCard(
          index: 1,
          icon: Icons.science_outlined,
          iconColor: const Color(0xFF0284C7),
          title: 'Technical Specifications',
          subtitle: 'Active ingredients, dosage & PHI',
          trailingBadge: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
            ),
            child: Text(
              widget.product.category,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDarkGreen,
              ),
            ),
          ),
          content: _buildTechnicalSpecsContent(isMobile: true),
        ),

        // 3. Application Guide Accordion Card
        _buildAccordionCard(
          index: 2,
          icon: Icons.water_drop_outlined,
          iconColor: const Color(0xFF0D9488),
          title: 'Application & Dosage Guide',
          subtitle: 'Spraying instructions & safety precautions',
          content: _buildApplicationGuideContent(isMobile: true),
        ),

        // 4. Farmer Reviews Accordion Card
        _buildAccordionCard(
          index: 3,
          icon: Icons.star_rounded,
          iconColor: AppColors.ratingAmber,
          title: 'Farmer Reviews ($_totalReviewsCount)',
          subtitle: '${_averageRating.toStringAsFixed(1)} ★ verified grower feedback',
          trailingBadge: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, size: 12, color: AppColors.ratingAmber),
                const SizedBox(width: 3),
                Text(
                  _averageRating.toStringAsFixed(1),
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
          content: _buildReviewsContent(isMobile: true),
        ),
      ],
    );
  }

  /// Individual Collapsible Accordion Card for Mobile
  Widget _buildAccordionCard({
    required int index,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailingBadge,
    required Widget content,
  }) {
    final isExpanded = _expandedMobileSections.contains(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? AppColors.primaryGreen.withValues(alpha: 0.35) : const Color(0xFFE2E8F0),
          width: isExpanded ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isExpanded ? 0.04 : 0.015),
            blurRadius: isExpanded ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedMobileSections.remove(index);
                } else {
                  _expandedMobileSections.add(index);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isExpanded ? AppColors.lightGreen : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: isExpanded ? AppColors.primaryGreen : iconColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isExpanded ? AppColors.primaryGreen : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailingBadge != null) ...[
                    trailingBadge,
                    const SizedBox(width: 8),
                  ],
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Animated Expanded Body
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: content,
                ),
              ],
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }

  /// Desktop Experience: Full Width Segmented Tab Bar
  Widget _buildDesktopTabsSection() {
    final tabItems = [
      (
        label: 'Product Overview',
        icon: Icons.info_outline_rounded,
      ),
      (
        label: 'Technical Specs',
        icon: Icons.science_outlined,
      ),
      (
        label: 'Application Guide',
        icon: Icons.water_drop_outlined,
      ),
      (
        label: 'Farmer Reviews ($_totalReviewsCount)',
        icon: Icons.star_rounded,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Desktop Tab Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                for (int i = 0; i < tabItems.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _activeTabIndex = i;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: _activeTabIndex == i ? AppColors.primaryGreen : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _activeTabIndex == i ? AppColors.primaryGreen : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                        boxShadow: _activeTabIndex == i
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryGreen.withValues(alpha: 0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tabItems[i].icon,
                            size: 16,
                            color: _activeTabIndex == i
                                ? Colors.white
                                : (i == 3 ? AppColors.ratingAmber : AppColors.textSecondary),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tabItems[i].label,
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              fontWeight: _activeTabIndex == i ? FontWeight.w700 : FontWeight.w500,
                              color: _activeTabIndex == i ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Tab Body
          Padding(
            padding: const EdgeInsets.all(22),
            child: _buildActiveTabContent(isMobile: false),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent({required bool isMobile}) {
    switch (_activeTabIndex) {
      case 0:
        return _buildOverviewContent(isMobile: isMobile);
      case 1:
        return _buildTechnicalSpecsContent(isMobile: isMobile);
      case 2:
        return _buildApplicationGuideContent(isMobile: isMobile);
      case 3:
      default:
        return _buildReviewsContent(isMobile: isMobile);
    }
  }

  Widget _buildOverviewContent({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About ${widget.product.title}',
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 14.5 : 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.product.title} is a premium agricultural formulation manufactured by ${widget.product.vendor} and distributed directly through EBS Essential BioCrop Science. Engineered for Indian climatic and soil conditions, it provides dependable crop protection and enhanced yield vitality.',
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 12.5 : 13.5,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Key Benefits:',
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _buildBulletPoint('Rapid systemic action and extended residual efficacy in all growing seasons.', isMobile),
        _buildBulletPoint('Safe for beneficial insects when used according to standard label recommendations.', isMobile),
        _buildBulletPoint('100% genuine batch authenticated with EBS lab purity certification.', isMobile),
        _buildBulletPoint('Compatible with common tank-mix combinations without phytotoxicity risks.', isMobile),
      ],
    );
  }

  Widget _buildTechnicalSpecsContent({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Technical Specifications & Composition',
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 14.5 : 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildSpecRow('Active Ingredient', widget.product.technicalName, isMobile),
        _buildSpecRow('Formulation Category', widget.product.category, isMobile),
        _buildSpecRow('Manufacturer', widget.product.vendor, isMobile),
        _buildSpecRow('Recommended Dosage', '1.5 - 2.0 ml / gm per liter of water (or 150-200 Ltr/acre)', isMobile),
        _buildSpecRow('Target Crops', 'Cotton, Paddy, Chili, Tomato, Sugarcane, Soybean, Pulses, Fruits', isMobile),
        _buildSpecRow('Pre-Harvest Interval (PHI)', '7 - 14 Days depending on crop stage', isMobile),
      ],
    );
  }

  Widget _buildApplicationGuideContent({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How to Apply & Safety Guidelines',
          style: GoogleFonts.poppins(
            fontSize: isMobile ? 14.5 : 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _buildBulletPoint('Spray during cool morning or late afternoon hours to maximize leaf absorption.', isMobile),
        _buildBulletPoint('Use clean water free from mud or heavy organic sediment for tank preparation.', isMobile),
        _buildBulletPoint('Wear protective gloves and mask while handling chemical concentrates.', isMobile),
        _buildBulletPoint('Store in original container away from direct sunlight and children.', isMobile),
      ],
    );
  }

  Widget _buildBulletPoint(String text, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, size: 15, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: isMobile ? 12 : 13,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, bool isMobile) {
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  /// Full-featured Reviews Section with Interactive "Add Review" form, Multi-Image, and Video Uploads
  Widget _buildReviewsContent({required bool isMobile}) {
    final mediaReviews = _reviews.where((r) => r.imageUrls.isNotEmpty || r.videoName != null).toList();
    final fiveStarReviews = _reviews.where((r) => r.rating == 5).toList();

    List<FarmerReviewItem> displayedReviews = _reviews;
    if (_selectedReviewFilter == 'media') {
      displayedReviews = mediaReviews;
    } else if (_selectedReviewFilter == '5star') {
      displayedReviews = fiveStarReviews;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Rating Header & "Write a Review" Action Bar
        Container(
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  // Score & Stars
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _averageRating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 26 : 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int i = 0; i < 5; i++)
                                  const Icon(Icons.star_rounded, size: 18, color: AppColors.ratingAmber),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Based on $_totalReviewsCount verified farmer reviews',
                              style: GoogleFonts.poppins(
                                fontSize: isMobile ? 11 : 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // "Write a Review" Action Button
                  ElevatedButton.icon(
                    onPressed: _toggleReviewForm,
                    icon: Icon(
                      _isWritingReview ? Icons.close_rounded : Icons.rate_review_rounded,
                      size: 16,
                    ),
                    label: Text(
                      _isWritingReview ? 'Close Form' : 'Write a Review',
                      style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isWritingReview ? const Color(0xFF64748B) : AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              // Verified Feedback guarantee note
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.verified_rounded, size: 14, color: AppColors.primaryGreen),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      '100% Authenticated field purchases by Indian farmers & agronomists',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDarkGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Interactive "Add Review" Form (Animated Expansion)
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity, height: 0),
          secondChild: _buildAddReviewForm(isMobile),
          crossFadeState: _isWritingReview ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),

        if (_isWritingReview) const SizedBox(height: 16),

        // 3. Review Filter Chips Bar
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildReviewFilterChip(
              id: 'all',
              label: 'All Reviews ($_totalReviewsCount)',
              icon: Icons.reviews_outlined,
            ),
            _buildReviewFilterChip(
              id: 'media',
              label: 'With Photos & Videos (${mediaReviews.length})',
              icon: Icons.photo_library_outlined,
            ),
            _buildReviewFilterChip(
              id: '5star',
              label: '5 Star (${fiveStarReviews.length})',
              icon: Icons.star_rounded,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 4. Reviews List
        if (displayedReviews.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                const Icon(Icons.rate_review_outlined, size: 40, color: AppColors.textMuted),
                const SizedBox(height: 10),
                Text(
                  'No reviews matching this filter.',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Be the first to share your field experience!',
                  style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textMuted),
                ),
              ],
            ),
          )
        else
          for (int i = 0; i < displayedReviews.length; i++) ...[
            if (i > 0) const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),
            _buildFarmerReviewCard(displayedReviews[i], isMobile),
          ],
      ],
    );
  }

  /// Toggle and Reset Review Form Handlers
  void _toggleReviewForm() {
    setState(() {
      _isWritingReview = !_isWritingReview;
      _formValidationError = null;
    });
  }

  void _resetReviewForm() {
    _reviewAuthorController.clear();
    _reviewRoleController.clear();
    _reviewTitleController.clear();
    _reviewCommentController.clear();
    _newReviewImages.clear();
    _newReviewVideo = null;
    _newReviewRating = 5;
    _newReviewCrop = 'Cotton';
    _formValidationError = null;
  }

  /// Review Filter Chip Builder
  Widget _buildReviewFilterChip({
    required String id,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedReviewFilter == id;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedReviewFilter = id;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppColors.primaryDarkGreen : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primaryDarkGreen : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The Full "Add Review" Form Widget
  Widget _buildAddReviewForm(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.rate_review_rounded, color: AppColors.primaryGreen, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share Your Field Experience',
                      style: GoogleFonts.poppins(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Provide crop details, dosage, results, photos, and video demonstration',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),

          // Error validation alert
          if (_formValidationError != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF87171)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.primaryCrimson, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formValidationError!,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Section 1: Rating Selection
          Text(
            'Overall Rating *',
            style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              for (int i = 1; i <= 5; i++)
                InkWell(
                  onTap: () {
                    setState(() {
                      _newReviewRating = i;
                    });
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Icon(
                      Icons.star_rounded,
                      size: isMobile ? 32 : 36,
                      color: i <= _newReviewRating ? AppColors.ratingAmber : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getRatingLabel(_newReviewRating),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Section 2: Reviewer Name & Location
          if (isMobile) ...[
            _buildTextField(
              controller: _reviewAuthorController,
              label: 'Your Name *',
              hint: 'e.g. Ramesh Patil',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _reviewRoleController,
              label: 'Location / Occupation',
              hint: 'e.g. Cotton Grower, Jalna (MH)',
              icon: Icons.location_on_outlined,
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _reviewAuthorController,
                    label: 'Your Name *',
                    hint: 'e.g. Ramesh Patil',
                    icon: Icons.person_outline_rounded,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildTextField(
                    controller: _reviewRoleController,
                    label: 'Location / Occupation',
                    hint: 'e.g. Cotton Grower, Jalna (MH)',
                    icon: Icons.location_on_outlined,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),

          // Section 3: Target Crop Selector
          Text(
            'Target Crop Treated:',
            style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final crop in ['Cotton', 'Chilli', 'Paddy', 'Sugarcane', 'Soybean', 'Tomato', 'Pomegranate', 'Other'])
                ChoiceChip(
                  label: Text(crop),
                  selected: _newReviewCrop == crop,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _newReviewCrop = crop;
                      });
                    }
                  },
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: _newReviewCrop == crop ? FontWeight.w700 : FontWeight.w500,
                    color: _newReviewCrop == crop ? Colors.white : AppColors.textPrimary,
                  ),
                  selectedColor: AppColors.primaryGreen,
                  backgroundColor: const Color(0xFFF1F5F9),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  showCheckmark: false,
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Section 4: Title & Detailed Review
          _buildTextField(
            controller: _reviewTitleController,
            label: 'Review Headline *',
            hint: 'e.g. Outstanding pest knockdown within 48 hours',
            icon: Icons.title_rounded,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _reviewCommentController,
            label: 'Detailed Crop Experience *',
            hint: 'Mention pest/disease attack severity, dosage per pump/acre, knockdown time, crop safety, and yield response...',
            icon: Icons.description_outlined,
            maxLines: 4,
          ),

          const SizedBox(height: 16),

          // Section 5: Multiple Images Upload
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_camera_rounded, size: 16, color: AppColors.primaryGreen),
                  const SizedBox(width: 6),
                  Text(
                    'Upload Field Photos',
                    style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_newReviewImages.length} / 5 photos',
                  style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.primaryDarkGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Photos Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Render already attached photos
                for (int i = 0; i < _newReviewImages.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        InkWell(
                          onTap: () => _showImageZoomDialog(context, _newReviewImages[i], 'Attached Field Photo #${i + 1}'),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primaryGreen, width: 1.5),
                              color: const Color(0xFFF8FAFC),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              _newReviewImages[i],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_rounded, size: 28, color: AppColors.textMuted),
                            ),
                          ),
                        ),
                        // Delete Button
                        Positioned(
                          top: -6,
                          right: -6,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _newReviewImages.removeAt(i);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryCrimson,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // "+ Add Photo" button if less than 5
                if (_newReviewImages.length < 5) ...[
                  InkWell(
                    onTap: () => _openPhotoPickerDialog(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 80,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_outlined, size: 22, color: AppColors.primaryGreen),
                          const SizedBox(height: 4),
                          Text(
                            '+ Add Photo',
                            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primaryGreen),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Section 6: Video Upload
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.videocam_rounded, size: 16, color: AppColors.primaryCrimson),
                  const SizedBox(width: 6),
                  Text(
                    'Upload Field Video Demonstration',
                    style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Text(
                'MP4 (max 50MB)',
                style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_newReviewVideo == null) ...[
            InkWell(
              onTap: () => _openVideoPickerDialog(context),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.video_call_rounded, color: AppColors.primaryCrimson, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '+ Attach Crop Spray or Trial Video',
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          Text(
                            'Click to select recorded field demonstration or efficacy result video',
                            style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.upload_file_rounded, color: AppColors.textSecondary, size: 20),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Attached Video Card
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryCrimson.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _showVideoPlayerDialog(
                      context,
                      _newReviewVideo!['name']!,
                      _newReviewVideo!['duration']!,
                      _newReviewVideo!['thumb'],
                      _reviewAuthorController.text.trim().isEmpty ? 'Your Video' : _reviewAuthorController.text.trim(),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            _newReviewVideo!['thumb']!,
                            width: 60,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 60,
                              height: 48,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 13, color: AppColors.primaryGreen),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _newReviewVideo!['name']!,
                                style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_newReviewVideo!['duration']} • ${_newReviewVideo!['size']} • Tap preview',
                          style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _newReviewVideo = null;
                      });
                    },
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.primaryCrimson, size: 20),
                    tooltip: 'Remove video',
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),

          // Section 7: Form Submission Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _resetReviewForm();
                    _isWritingReview = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _submitReview,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                label: Text(
                  'Submit Verified Review',
                  style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper to build standardized text input fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textMuted),
            prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 5:
        return '⭐ 5 - Excellent (Highly Recommended)';
      case 4:
        return '⭐ 4 - Very Good Result';
      case 3:
        return '⭐ 3 - Good / Satisfactory';
      case 2:
        return '⭐ 2 - Below Expectations';
      case 1:
      default:
        return '⭐ 1 - Unsatisfactory';
    }
  }

  /// Action: Submit Review handler
  void _submitReview() {
    final author = _reviewAuthorController.text.trim();
    final comment = _reviewCommentController.text.trim();
    final title = _reviewTitleController.text.trim();
    final role = _reviewRoleController.text.trim();

    if (author.isEmpty) {
      setState(() {
        _formValidationError = 'Please enter your name or farm name.';
      });
      return;
    }

    if (comment.isEmpty || comment.length < 8) {
      setState(() {
        _formValidationError = 'Please provide detailed field feedback (minimum 8 characters).';
      });
      return;
    }

    final newReview = FarmerReviewItem(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      authorName: author,
      authorRole: role.isEmpty ? 'Farmer, Verified Buyer' : role,
      rating: _newReviewRating,
      title: title.isEmpty ? 'Farmer Review' : title,
      comment: comment,
      date: 'Just now',
      isVerified: true,
      cropType: _newReviewCrop,
      imageUrls: List.from(_newReviewImages),
      videoName: _newReviewVideo?['name'],
      videoDuration: _newReviewVideo?['duration'],
      videoSize: _newReviewVideo?['size'],
      videoThumbnailUrl: _newReviewVideo?['thumb'],
    );

    setState(() {
      _reviews.insert(0, newReview);
      _resetReviewForm();
      _isWritingReview = false;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Thank you $author! Your verified review and media have been published.',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryDarkGreen,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Dialog to Pick Field Photos (Presets or Custom URL)
  void _openPhotoPickerDialog(BuildContext context) {
    final samplePhotos = [
      (
        title: 'Treated Plot Crop Recovery',
        url: 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=600&auto=format&fit=crop&q=80',
      ),
      (
        title: 'Foliar Knockdown & Clean Leaves',
        url: 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=600&auto=format&fit=crop&q=80',
      ),
      (
        title: 'Agronomist Field Inspection',
        url: 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=600&auto=format&fit=crop&q=80',
      ),
      (
        title: 'Package Authenticity & Seal Check',
        url: widget.product.imageUrl,
      ),
    ];

    final customUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_photo_alternate_rounded, color: AppColors.primaryGreen, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Attach Field Photos',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select representative crop photos to attach to your review:',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      for (final photo in samplePhotos) ...[
                        InkWell(
                          onTap: () {
                            if (_newReviewImages.length < 5 && !_newReviewImages.contains(photo.url)) {
                              setState(() {
                                _newReviewImages.add(photo.url);
                              });
                              Navigator.pop(ctx);
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _newReviewImages.contains(photo.url)
                                  ? AppColors.lightGreen.withValues(alpha: 0.3)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _newReviewImages.contains(photo.url)
                                    ? AppColors.primaryGreen
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    photo.url,
                                    width: 46,
                                    height: 46,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_rounded, size: 28),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    photo.title,
                                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                if (_newReviewImages.contains(photo.url))
                                  const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 20)
                                else
                                  const Icon(Icons.add_circle_outline_rounded, color: AppColors.textMuted, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Text(
                        'Or Custom Photo Link:',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: customUrlController,
                              style: GoogleFonts.poppins(fontSize: 12),
                              decoration: InputDecoration(
                                hintText: 'https://...',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final text = customUrlController.text.trim();
                              if (text.isNotEmpty && _newReviewImages.length < 5) {
                                setState(() {
                                  _newReviewImages.add(text);
                                });
                                Navigator.pop(ctx);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Attach', style: GoogleFonts.poppins(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Close', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Dialog to Pick Field Video Demonstration
  void _openVideoPickerDialog(BuildContext context) {
    final sampleVideos = [
      (
        title: 'Crop Spray Trial Demonstration',
        duration: '0:45 min',
        size: '16.8 MB',
        thumb: 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=600&auto=format&fit=crop&q=80',
        file: '${widget.product.title.split(' ').first.toLowerCase()}_field_demonstration.mp4',
      ),
      (
        title: 'Tank-Mix & Foliar Application Trial',
        duration: '1:12 min',
        size: '22.4 MB',
        thumb: 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=600&auto=format&fit=crop&q=80',
        file: '${widget.product.title.split(' ').first.toLowerCase()}_tankmix_trial.mp4',
      ),
      (
        title: 'Pre & Post Knockdown Trial Results',
        duration: '0:35 min',
        size: '12.1 MB',
        thumb: 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=600&auto=format&fit=crop&q=80',
        file: '${widget.product.title.split(' ').first.toLowerCase()}_efficacy_trial.mp4',
      ),
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.videocam_rounded, color: AppColors.primaryCrimson, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Upload Field Demonstration Video',
                style: GoogleFonts.poppins(fontSize: 15.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select a field video clip recording crop trial or application results:',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                for (final vid in sampleVideos) ...[
                  InkWell(
                    onTap: () {
                      setState(() {
                        _newReviewVideo = {
                          'name': vid.file,
                          'duration': vid.duration,
                          'size': vid.size,
                          'thumb': vid.thumb,
                        };
                      });
                      Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  vid.thumb,
                                  width: 52,
                                  height: 42,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 52,
                                    height: 42,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const CircleAvatar(
                                radius: 11,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vid.title,
                                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${vid.file} • ${vid.duration} (${vid.size})',
                                  style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
            ),
          ],
        );
      },
    );
  }

  /// Fullscreen / Large Photo Zoom Modal
  void _showImageZoomDialog(BuildContext context, String imageUrl, String caption) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Modal Top Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.camera_alt_outlined, size: 16, color: AppColors.primaryGreen),
                            const SizedBox(width: 6),
                            Text(
                              caption,
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded, size: 20),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                  Flexible(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Padding(
                        padding: EdgeInsets.all(32),
                        child: Icon(Icons.broken_image_rounded, size: 60, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Interactive Video Demonstration Player Modal
  void _showVideoPlayerDialog(
    BuildContext context,
    String videoName,
    String duration,
    String? thumbUrl,
    String author,
  ) {
    bool isPlaying = true;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setVideoState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Video Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.play_circle_filled_rounded, color: AppColors.primaryCrimson, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  videoName,
                                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(ctx),
                              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                      ),

                      // Video Viewport Simulator
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (thumbUrl != null)
                              Image.network(
                                thumbUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
                              )
                            else
                              Container(color: Colors.black),

                            // Overlay gradient
                            Container(
                              color: Colors.black.withValues(alpha: 0.35),
                            ),

                            // Centered Play/Pause Button
                            InkWell(
                              onTap: () {
                                setVideoState(() {
                                  isPlaying = !isPlaying;
                                });
                              },
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.9),
                                child: Icon(
                                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),

                            // Bottom Controls Strip
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                color: Colors.black.withValues(alpha: 0.75),
                                child: Row(
                                  children: [
                                    Icon(
                                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '0:18 / $duration',
                                      style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.white),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(2),
                                        child: const LinearProgressIndicator(
                                          value: 0.42,
                                          backgroundColor: Colors.white24,
                                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                                          minHeight: 4,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(Icons.volume_up_rounded, color: Colors.white, size: 16),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Caption & Agri Context
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_rounded, color: AppColors.primaryGreen, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Field trial demonstration recorded by $author • Verified EBS Batch Purchase',
                                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFCBD5E1)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Single Review Card in the Reviews List
  Widget _buildFarmerReviewCard(FarmerReviewItem item, bool isMobile) {
    // Generate Initials
    final initials = item.authorName
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Initials Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.lightGreen,
                child: Text(
                  initials.isEmpty ? 'F' : initials,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDarkGreen,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Author & Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.authorName,
                                style: GoogleFonts.poppins(
                                  fontSize: isMobile ? 12.5 : 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                item.authorRole,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Rating Stars & Date
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int i = 0; i < item.rating; i++)
                                  const Icon(Icons.star_rounded, size: 14, color: AppColors.ratingAmber),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.date,
                              style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (item.isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.lightGreen,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_rounded, size: 11, color: AppColors.primaryDarkGreen),
                                const SizedBox(width: 3),
                                Text(
                                  'Verified Buyer',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDarkGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (item.cropType != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '🌾 ${item.cropType}',
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Review Title
          Text(
            item.title,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 12.5 : 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          // Review Comment Text
          Text(
            item.comment,
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 11.5 : 12.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),

          // Photos Gallery (if any)
          if (item.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Field Photos (${item.imageUrls.length}):',
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < item.imageUrls.length; i++) ...[
                    InkWell(
                      onTap: () => _showImageZoomDialog(
                        context,
                        item.imageUrls[i],
                        '${item.authorName} - Photo #${i + 1}',
                      ),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          item.imageUrls[i],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_rounded, size: 24, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Attached Video Tile (if any)
          if (item.videoName != null) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _showVideoPlayerDialog(
                context,
                item.videoName!,
                item.videoDuration ?? '0:45 min',
                item.videoThumbnailUrl,
                item.authorName,
              ),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: item.videoThumbnailUrl != null
                              ? Image.network(
                                  item.videoThumbnailUrl!,
                                  width: 48,
                                  height: 38,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(width: 48, height: 38, color: Colors.black87),
                                )
                              : Container(width: 48, height: 38, color: Colors.black87),
                        ),
                        const CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.black54,
                          child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.videocam_rounded, size: 14, color: AppColors.primaryCrimson),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.videoName!,
                                  style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${item.videoDuration ?? "0:45 min"} • Verified field demonstration video',
                            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.play_circle_outline_rounded, color: AppColors.primaryGreen, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSimilarProductsSection(List<ProductItem> similarProducts, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Professional Section Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 18,
            vertical: isMobile ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 3.5,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Similar Products',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${similarProducts.length} items',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDarkGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Matches ${widget.product.category}',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 3.5,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Similar Products',
                          style: GoogleFonts.poppins(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${similarProducts.length} items',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDarkGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Flexible(
                      child: Text(
                        'Matches ${widget.product.category}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 6;
            double childAspectRatio = 0.78;
            double crossAxisSpacing = 16;
            double mainAxisSpacing = 16;

            if (constraints.maxWidth < 600) {
              crossAxisCount = 2;
              childAspectRatio = 0.68;
              crossAxisSpacing = 8;
              mainAxisSpacing = 8;
            } else if (constraints.maxWidth < 850) {
              crossAxisCount = 3;
              childAspectRatio = 0.72;
              crossAxisSpacing = 10;
              mainAxisSpacing = 10;
            } else if (constraints.maxWidth < 1180) {
              crossAxisCount = 4;
              childAspectRatio = 0.74;
              crossAxisSpacing = 12;
              mainAxisSpacing = 12;
            } else if (constraints.maxWidth < 1520) {
              crossAxisCount = 5;
              childAspectRatio = 0.76;
              crossAxisSpacing = 14;
              mainAxisSpacing = 14;
            } else {
              crossAxisCount = 6;
              childAspectRatio = 0.78;
              crossAxisSpacing = 16;
              mainAxisSpacing = 16;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: mainAxisSpacing,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: similarProducts.length,
              itemBuilder: (context, index) {
                final prod = similarProducts[index];
                return ProductCard(
                  product: prod,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailView(product: prod),
                      ),
                    );
                  },
                  onAddToCart: (p, v) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Added ${p.title} (${v.label}) to cart',
                                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        action: SnackBarAction(
                          label: 'VIEW CART',
                          textColor: Colors.white,
                          onPressed: () {
                            _scaffoldKey.currentState?.openEndDrawer();
                          },
                        ),
                        backgroundColor: AppColors.primaryGreen,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  },
                  onBuyNow: (p, v) {
                    _scaffoldKey.currentState?.openEndDrawer();
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

/// Data Model representing verified farmer reviews with multi-image and video assets
class FarmerReviewItem {
  final String id;
  final String authorName;
  final String authorRole;
  final int rating;
  final String title;
  final String comment;
  final String date;
  final bool isVerified;
  final String? cropType;
  final List<String> imageUrls;
  final String? videoName;
  final String? videoDuration;
  final String? videoSize;
  final String? videoThumbnailUrl;

  const FarmerReviewItem({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.rating,
    required this.title,
    required this.comment,
    required this.date,
    this.isVerified = true,
    this.cropType,
    this.imageUrls = const [],
    this.videoName,
    this.videoDuration,
    this.videoSize,
    this.videoThumbnailUrl,
  });
}
