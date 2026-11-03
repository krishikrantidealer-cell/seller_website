import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:seller_website/data/models/catalog_models.dart';
import 'package:seller_website/data/services/category_api_service.dart';
import 'package:seller_website/data/services/product_api_service.dart';
import 'package:seller_website/core/network/api_client.dart';
import 'package:seller_website/core/network/websocket_service.dart';
import 'package:seller_website/data/datasources/category_remote_datasource.dart';
import 'package:seller_website/data/datasources/product_remote_datasource.dart';
import 'package:seller_website/data/repositories/category_repository_impl.dart';
import 'package:seller_website/data/repositories/product_repository_impl.dart';
import 'package:seller_website/logic/category/category_bloc.dart';
import 'package:seller_website/logic/category/category_event.dart';
import 'package:seller_website/logic/product/product_bloc.dart';
import 'package:seller_website/logic/product/product_event.dart';
import 'package:seller_website/main.dart';
import 'package:seller_website/presentation/product_detail/product_detail_view.dart';
import 'package:seller_website/data/models/auth_state.dart';
import 'package:seller_website/presentation/profile/farmer_profile_view.dart';
import 'package:seller_website/presentation/widgets/category_ribbon.dart';
import 'package:seller_website/presentation/widgets/product_card.dart';
import 'package:seller_website/data/models/order_models.dart';
import 'package:seller_website/presentation/orders/my_orders_view.dart';
import 'package:seller_website/presentation/orders/order_detail_view.dart';
import 'package:seller_website/presentation/widgets/auth_modal.dart';
import 'package:seller_website/presentation/widgets/web_footer.dart';
import 'package:seller_website/presentation/widgets/main_nav_header.dart';
import 'package:seller_website/presentation/technical/technical_search_view.dart';
import 'package:seller_website/data/models/wishlist_state.dart';
import 'package:seller_website/presentation/wishlist/wishlist_view.dart';
import 'package:seller_website/presentation/category/category_detail_view.dart';
import 'package:seller_website/presentation/home/home_view.dart';
import 'package:seller_website/presentation/widgets/app_product_image.dart';

void main() {
  setUp(() {
    CategoryController.instance.resetToSampleCategories();
    ProductController.instance.resetToSampleProducts();
  });

  testWidgets('SellerWebsiteApp smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SellerWebsiteApp());
    await tester.pump();

    expect(find.textContaining('BioCrop'), findsWidgets);
    expect(find.text('Track Order'), findsOneWidget);

    // Verify Add to Cart button exists on catalog cards and Buy Now is removed
    final addToCartBtn = find.widgetWithText(ElevatedButton, 'Add to Cart').first;
    expect(addToCartBtn, findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Buy Now'), findsNothing);

    // Scroll to and tap Add to Cart to open variants modal
    await tester.ensureVisible(addToCartBtn);
    await tester.pumpAndSettle();
    await tester.tap(addToCartBtn);
    await tester.pumpAndSettle();

    // Verify variants modal opens with pack size options
    expect(find.textContaining('Select Pack Size'), findsWidgets);
    final addVariantBtn = find.widgetWithText(ElevatedButton, 'Add').first;
    expect(addVariantBtn, findsOneWidget);

    // Tap Add on the first variant
    await tester.tap(addVariantBtn);
    await tester.pumpAndSettle();

    // Verify in-cart indicator or stepper reflects the added item
    expect(find.text('Qty: 1'), findsWidgets);

    // Tap View Cart in the variants modal
    final viewCartBtn = find.textContaining('View Cart');
    expect(viewCartBtn, findsWidgets);
    await tester.tap(viewCartBtn.first);
    await tester.pumpAndSettle();

    // Verify cart sidebar (QuickCartDrawer) opened
    expect(find.text('My Cart'), findsOneWidget);
  });

  testWidgets('Phone number and OTP login flow test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SellerWebsiteApp());
    await tester.pump();

    // Find and tap Login / My Account button in header
    final accountBtn = find.widgetWithText(OutlinedButton, 'Login / My Account');
    expect(accountBtn, findsOneWidget);
    await tester.tap(accountBtn);
    await tester.pumpAndSettle();

    // Verify Phone input modal appears
    expect(find.text('Farmer Login / Register'), findsOneWidget);
    expect(find.text('+91'), findsOneWidget);

    // Tap Quick Test demo number to fill 9876543210
    final quickTestBtn = find.textContaining('Quick Test: Tap to fill demo number');
    expect(quickTestBtn, findsOneWidget);
    await tester.tap(quickTestBtn);
    await tester.pumpAndSettle();

    // Tap Get OTP via SMS
    final getOtpBtn = find.widgetWithText(ElevatedButton, 'Get OTP via SMS');
    expect(getOtpBtn, findsOneWidget);
    await tester.tap(getOtpBtn);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify OTP Verification view appears
    expect(find.text('Verify Mobile OTP'), findsOneWidget);
    expect(find.textContaining('9876543210'), findsWidgets);

    // Tap Test Mode auto-verify button (or fill 1234)
    final autoVerifyBtn = find.textContaining('Test Mode: Tap to auto-verify');
    expect(autoVerifyBtn, findsOneWidget);
    await tester.tap(autoVerifyBtn);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // Verify User is logged in with phone number and no dummy name is shown
    expect(find.text('Kisan Farmer'), findsNothing);
    expect(find.textContaining('98765 43210'), findsWidgets);

    // Tap the account button to open the dropdown menu
    final loggedInAccount = find.textContaining('98765 43210').first;
    await tester.tap(loggedInAccount);
    await tester.pumpAndSettle();

    // Verify Dropdown menu is visible with Farmer Profile, Track Orders and Sign Out
    expect(find.text('Farmer Profile'), findsOneWidget);
    expect(find.text('Track Orders'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
    // Verify Cart and Helpline are not in the dropdown
    expect(find.text('Krishi Helpline'), findsNothing);

    // Tap Sign Out from dropdown
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    // Verify Sign Out confirmation popup appears
    expect(find.text('Sign Out from BioCrop?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Yes, Sign Out'), findsOneWidget);

    // Tap Cancel - should dismiss popup and keep user logged in
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.textContaining('98765 43210'), findsWidgets);

    // Open dropdown again and tap Sign Out
    await tester.tap(find.textContaining('98765 43210').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    // Tap Yes, Sign Out on confirmation popup
    await tester.tap(find.text('Yes, Sign Out'));
    await tester.pumpAndSettle();

    // Verify user is logged out back to Login / My Account
    expect(find.widgetWithText(OutlinedButton, 'Login / My Account'), findsOneWidget);
  });

  testWidgets('Best Sellers View All shows only Best Seller products', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SellerWebsiteApp());
    await tester.pump();

    // Verify button says "View All" on desktop (not "View All Products")
    expect(find.text('View All Products'), findsNothing);
    final viewAllBtn = find.text('View All');
    expect(viewAllBtn, findsOneWidget);

    // Tap View All on Best Sellers section
    await tester.tap(viewAllBtn);
    await tester.pumpAndSettle();

    // Verify CategoryDetailView opens in Best Sellers mode
    expect(find.byType(CategoryDetailView), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);
    expect(find.text('Featured'), findsOneWidget);
    // Categories filter chips should NOT be displayed in Best Sellers view
    expect(find.text('All Products'), findsNothing);
    expect(find.text('Insecticides'), findsNothing);
    // Non-bestseller products should NOT be displayed
    expect(find.textContaining('Nano Urea'), findsNothing);
    expect(find.textContaining('Tata Rallis'), findsNothing);
  });

  testWidgets('Mobile view displays phone number and opens dropdown when tapped', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SellerWebsiteApp());
    await tester.pump();

    // Tap login button
    final loginIconBtn = find.byTooltip('Login / My Account');
    expect(loginIconBtn, findsOneWidget);
    await tester.tap(loginIconBtn);
    await tester.pumpAndSettle();

    // Quick test demo fill
    await tester.tap(find.textContaining('Quick Test: Tap to fill demo number'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Get OTP via SMS'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Auto verify
    await tester.tap(find.textContaining('Test Mode: Tap to auto-verify'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // In mobile view, the phone number should be displayed directly in header
    expect(find.text('Kisan Farmer'), findsNothing);
    expect(find.textContaining('98765 43210'), findsWidgets);

    // Tapping the phone number opens the dropdown menu
    await tester.tap(find.textContaining('98765 43210').first);
    await tester.pumpAndSettle();

    // Verify dropdown menu opened with Track Orders and Sign Out
    expect(find.text('Track Orders'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
  });

  testWidgets('Product detail back button starts from the left side and navigates back', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SellerWebsiteApp());
    await tester.pumpAndSettle();

    // Tap the first product card to open product detail view
    final firstProduct = find.byType(ProductCard).first;
    await tester.tap(firstProduct);
    await tester.pumpAndSettle();

    // Verify back button exists
    final backBtn = find.text('Back');
    expect(backBtn, findsOneWidget);

    // On a 1440px desktop screen, the back button should start from the left (< 100px), not centered (~500px+)
    final backBtnOffset = tester.getTopLeft(backBtn);
    expect(backBtnOffset.dx, lessThan(100.0));

    // Tap back button to navigate back to home
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // Verify we are back on the home page
    expect(find.text('Best Sellers'), findsWidgets);
  });

  testWidgets('Major category hover opens categories and hovering category opens subcategories in the side', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SellerWebsiteApp());
    await tester.pumpAndSettle();

    // Hover over 'Seeds' in the category ribbon
    final seedsTab = find.text('Seeds').first;
    expect(seedsTab, findsOneWidget);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(seedsTab));
    await tester.pumpAndSettle();

    // Verify Categories list opened: "Vegetable Seeds" and "Field Crop Seeds"
    expect(find.text('Vegetable Seeds'), findsWidgets);
    expect(find.text('Field Crop Seeds'), findsWidgets);

    // Initial state: subcategories are NOT shown yet (saving space until category is hovered)
    expect(find.text('Tomato Seeds'), findsNothing);

    // Now hover over "Vegetable Seeds"
    final vegSeeds = find.text('Vegetable Seeds').first;
    await gesture.moveTo(tester.getCenter(vegSeeds));
    await tester.pumpAndSettle();

    // Verify subcategories in the side panel opened for Vegetable Seeds
    expect(find.text('Tomato Seeds'), findsOneWidget);

    // Click subcategory "Tomato Seeds"
    await tester.tap(find.text('Tomato Seeds'));
    await tester.pumpAndSettle();

    // Should filter by subcategory
    expect(find.textContaining('Tomato'), findsWidgets);
  });

  testWidgets('All 12 AgriBegri Major Categories are rendered and support cascaded 2-stage hover', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    CategoryController.instance.resetToSampleCategories();

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CategoryRibbon(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify all 12 AgriBegri major category names exist in the data model
    final expected12Categories = [
      'Crop Protection',
      'Crop Nutrition',
      'Seeds',
      'Fertilizers',
      'Equipments',
      'Irrigation',
      'Gardening',
      'Organic Farming',
      'Cattle & Bird Care',
      'Bulk',
      'Har Din Sasta',
      'Growth Regulators',
    ];

    expect(CategoryItem.sampleCategories.length, equals(12));
    for (final catName in expected12Categories) {
      expect(
        CategoryItem.sampleCategories.any((c) => c.name == catName),
        isTrue,
        reason: 'Major category $catName should exist in sampleCategories',
      );
    }

    // Hover over 'Crop Protection' in the category ribbon
    final cropProtectionTab = find.text('Crop Protection').first;
    expect(cropProtectionTab, findsOneWidget);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(cropProtectionTab));
    await tester.pumpAndSettle();

    // Verify Level 1 categories show: 'Insecticides', 'Fungicides', 'Bio Pesticides'
    expect(find.text('Insecticides'), findsWidgets);
    expect(find.text('Fungicides'), findsWidgets);
    expect(find.text('Bio Pesticides'), findsWidgets);

    // Initial state: Level 2 subcategories not rendered until Category is hovered
    expect(find.text('Bio Insecticide'), findsNothing);

    // Hover over 'Bio Pesticides' category
    final bioPesticidesCategory = find.text('Bio Pesticides').first;
    await gesture.moveTo(tester.getCenter(bioPesticidesCategory));
    await tester.pumpAndSettle();

    // Subcategories should now be visible in the side panel
    expect(find.text('Bio Insecticide'), findsOneWidget);
    expect(find.text('Bio Fungicide'), findsOneWidget);
    expect(find.text('Bio Miticide'), findsOneWidget);

    // Hover over 'Equipments' tab (category index 4) to verify alignment directly below the tab
    final equipmentsTab = find.text('Equipments').first;
    await gesture.moveTo(tester.getCenter(equipmentsTab));
    await tester.pumpAndSettle();

    expect(find.text('Spray Pump'), findsWidgets);
    final equipmentsPos = tester.getTopLeft(equipmentsTab);
    final sprayPumpFinder = find.text('Spray Pump').first;
    final popupPos = tester.getTopLeft(sprayPumpFinder);

    // Verify popup appears directly below Equipments tab horizontally (aligned with tab)
    expect((popupPos.dx - equipmentsPos.dx).abs() < 50.0, isTrue);
  });

  testWidgets('Category ribbon is responsive on laptop screens and opens subcategories to the left without cutting off', (WidgetTester tester) async {
    // Standard laptop screen size (1280 x 800)
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SellerWebsiteApp());
    await tester.pumpAndSettle();

    // Verify pinned ALL CATEGORIES is visible on the left
    expect(find.text('ALL CATEGORIES'), findsOneWidget);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);

    // Hover over 'Cattle & Bird Care' tab near the right edge
    expect(find.text('Cattle & Bird Care'), findsWidgets);
    final ribbonScroll = find.byType(SingleChildScrollView).first;
    final cattleFinder = find.text('Cattle & Bird Care').first;
    while (tester.getCenter(cattleFinder).dx > 1150) {
      await tester.drag(ribbonScroll, const Offset(-200, 0));
      await tester.pumpAndSettle();
    }

    await gesture.moveTo(tester.getCenter(cattleFinder));
    await tester.pumpAndSettle();

    // Level 1 category groups show (e.g. 'Fodder Seed')
    expect(find.text('Fodder Seed'), findsWidgets);

    // Hover over 'Fodder Seed' to open Level 2 subcategories flyout
    final fodderGroup = find.text('Fodder Seed').first;
    await gesture.moveTo(tester.getCenter(fodderGroup));
    await tester.pumpAndSettle();

    // Verify subcategories appear (e.g. 'Forages', 'Sorghum')
    expect(find.text('Forages'), findsOneWidget);
    expect(find.text('Sorghum'), findsOneWidget);

    // Check that 'Forages' and subcategory flyout do not exceed screen width (1280px)
    final foragesTopRight = tester.getTopRight(find.text('Forages').first);
    expect(foragesTopRight.dx <= 1280.0, isTrue, reason: 'Subcategories flyout must stay within visible screen boundary');
    final foragesTopLeft = tester.getTopLeft(find.text('Forages').first);
    expect(foragesTopLeft.dx >= 0.0, isTrue, reason: 'Subcategories flyout must not clip on left side of screen');
  });

  testWidgets('Hovered category dropdown allows scrolling categories list smoothly without closing overlay', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SellerWebsiteApp());
    await tester.pumpAndSettle();

    // Hover over 'Crop Protection' in the category ribbon
    final cropProtectionTab = find.text('Crop Protection').first;
    expect(cropProtectionTab, findsOneWidget);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(cropProtectionTab));
    await tester.pumpAndSettle();

    // Dropdown should be open with categories list and placeholder
    expect(find.text('CATEGORIES'), findsOneWidget);
    expect(find.text('Insecticides'), findsWidgets);
    expect(find.text('Explore Crop Protection'), findsOneWidget);

    // Scroll categories list down
    final categoriesScrollFinder = find.byType(ListView).first;
    await tester.drag(categoriesScrollFinder, const Offset(0, -180));
    await tester.pumpAndSettle();

    final scrollableState = tester.state<ScrollableState>(find.descendant(of: categoriesScrollFinder, matching: find.byType(Scrollable)));
    final offsetBeforeHover = scrollableState.position.pixels;
    expect(offsetBeforeHover, greaterThan(0.0));

    // Dropdown should STILL be open and not dismissed by scrolling
    expect(find.text('CATEGORIES'), findsOneWidget);
    expect(find.text('Explore Crop Protection'), findsOneWidget);

    // Hover over 'Bio Pesticides'
    final bioPesticidesFinder = find.text('Bio Pesticides').first;
    await gesture.moveTo(tester.getCenter(bioPesticidesFinder));
    await tester.pumpAndSettle();

    // Verify categories list does NOT automatically scroll to top
    final offsetAfterHover = scrollableState.position.pixels;
    expect(offsetAfterHover, equals(offsetBeforeHover));

    // Subcategories list is displayed
    expect(find.text('Bio Insecticide'), findsOneWidget);

    // Tap subcategory
    await tester.tap(find.text('Bio Insecticide'));
    await tester.pumpAndSettle();
  });

  testWidgets('Har Din Sasta tab renders in ribbon and can be scrolled to and tapped', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SellerWebsiteApp());
    await tester.pumpAndSettle();

    // Verify Har Din Sasta tab exists in the ribbon
    final harDinSastaFinder = find.text('Har Din Sasta');
    expect(harDinSastaFinder, findsWidgets);

    // If scroll arrow is present, clicking right arrow scrolls smoothly
    final rightArrow = find.byIcon(Icons.chevron_right_rounded);
    if (rightArrow.evaluate().isNotEmpty) {
      await tester.tap(rightArrow.first);
      await tester.pumpAndSettle();
    }

    // Har Din Sasta is interactive and selectable
    await tester.tap(harDinSastaFinder.first, warnIfMissed: false);
    await tester.pumpAndSettle();
  });

  testWidgets('Search by Technical Name opens directory and filters by formulation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SellerWebsiteApp());
    await tester.pumpAndSettle();

    // Click 'Search by Technical' button in navigation header
    final technicalBtn = find.text('Search by Technical');
    expect(technicalBtn, findsOneWidget);
    await tester.tap(technicalBtn);
    await tester.pumpAndSettle();

    // Verify Technical Search Directory View opened
    expect(find.text('Search Products By Technical Name'), findsOneWidget);
    expect(find.textContaining('Technical Formulations Starting With "C"'), findsOneWidget);

    // Enter search for Chlorantraniliprole into directory search field
    await tester.enterText(find.byType(TextField).last, 'Chlorantraniliprole');
    await tester.pumpAndSettle();

    // Verify formulation row appears
    expect(find.text('Chlorantraniliprole 18.5% SC'), findsOneWidget);
    expect(find.text('✓ 1 Products in Store'), findsOneWidget);

    // Click 'View Products'
    await tester.ensureVisible(find.text('View Products'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View Products'));
    await tester.pumpAndSettle();

    // Verify redirected to products list with technical formulation active
    expect(find.textContaining('Chlorantraniliprole 18.5% SC'), findsWidgets);
    expect(find.text('Katyayani All in One Insecticide for Crops'), findsOneWidget);
  });

  testWidgets('TechnicalSearchView renders compactly on mobile without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: TechnicalSearchView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Search Products By Technical Name'), findsOneWidget);
    expect(find.textContaining('Formulations'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TechnicalSearchView renders without overflow on narrow 320px screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: TechnicalSearchView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Search Products By Technical Name'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProductDetailView renders properly on mobile view without RenderFlex overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailView(product: ProductItem.sampleProducts.first),
      ),
    );
    await tester.pumpAndSettle();

    // Verify product title and price rendered without overflow
    expect(find.text(ProductItem.sampleProducts.first.title), findsWidgets);
    expect(find.textContaining('100% Authenticated field purchases'), findsOneWidget);

    // Expand Farmer Reviews mobile accordion
    final reviewsAccordion = find.textContaining('Farmer Reviews');
    await tester.ensureVisible(reviewsAccordion);
    await tester.tap(reviewsAccordion);
    await tester.pumpAndSettle();

    // Verify reviews content rendered without overflow
    expect(find.text('Write a Review'), findsOneWidget);
    expect(find.textContaining('100% Authenticated field purchases'), findsOneWidget);
  });

  testWidgets('ProductDetailView gallery hides thumbnail selector row when product has single image and shows thumbnails only when multiple images exist', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // 1. Single image product: thumbnail row must NOT be shown
    final singleImageProduct = ProductItem(
      id: 'SINGLE-001',
      title: 'Single Image Agro Fertilizer',
      technicalName: 'Acetobacter Bio-fertilizer',
      vendor: 'Patel Agro Traders',
      imageUrl: 'https://example.com/single.jpg',
      imageUrls: const ['https://example.com/single.jpg'],
      displayRate: 510,
      printedMrp: 1200,
      category: 'Bio Fertilizers',
      packSize: '1 Ltr',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailView(product: singleImageProduct),
      ),
    );
    await tester.pumpAndSettle();

    // Verify main image is shown
    expect(find.text('Single Image Agro Fertilizer'), findsWidgets);
    // Dummy thumbnail icons must NOT exist in the gallery
    expect(find.byIcon(Icons.science_rounded), findsNothing);
    // Since only 1 image exists, there is only 1 AppProductImage with single.jpg (the main display image), NO thumbnail AppProductImage
    expect(
      find.byWidgetPredicate((w) => w is AppProductImage && w.imageUrl == 'https://example.com/single.jpg'),
      findsOneWidget,
    );

    // 2. Multiple images product: thumbnail selectors row MUST be shown
    final multiImageProduct = ProductItem(
      id: 'MULTI-001',
      title: 'Multi Image Agro Input',
      technicalName: 'Azotobacter culture',
      vendor: 'Patel Agro Traders',
      imageUrl: 'https://example.com/img1.jpg',
      imageUrls: const [
        'https://example.com/img1.jpg',
        'https://example.com/img2.jpg',
        'https://example.com/img3.jpg',
      ],
      displayRate: 850,
      printedMrp: 1100,
      category: 'Bio Fertilizers',
      packSize: '1 Ltr',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailView(product: multiImageProduct),
      ),
    );
    await tester.pumpAndSettle();

    // Now thumbnail items img2 and img3 exist in the gallery
    expect(
      find.byWidgetPredicate((w) => w is AppProductImage && w.imageUrl == 'https://example.com/img2.jpg'),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate((w) => w is AppProductImage && w.imageUrl == 'https://example.com/img3.jpg'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.science_rounded), findsNothing);
  });

  testWidgets('ProductDetailView renders real description and verified specifications without hardcoded dummy technical specs or application guides', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final productWithHtml = ProductItem(
      id: 'DESC-001',
      title: 'EBS Acetobacter Bio Fertilizer',
      technicalName: 'Acetobacter 5x10^8 CFU/ml',
      vendor: 'Patel Agro Traders',
      description: '<p>Acetobacter fixes atmospheric nitrogen in sugarcane.</p><h3>Key Benefits</h3><ul><li>High yield enhancement</li><li>Soil microbial boost</li></ul>',
      imageUrl: 'https://example.com/acetobacter.jpg',
      imageUrls: const ['https://example.com/acetobacter.jpg'],
      displayRate: 510,
      printedMrp: 1200,
      category: 'Bio Fertilizers',
      packSize: '1 Ltr',
      sku: 'SKU-ACT-1L',
      hsnCode: '31010099',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailView(product: productWithHtml),
      ),
    );
    await tester.pumpAndSettle();

    // Verify tabs: Description & Specifications + Farmer Reviews
    expect(find.text('Description & Specifications'), findsOneWidget);
    expect(find.textContaining('Farmer Reviews'), findsWidgets);
    // Hardcoded fake tabs must NOT exist
    expect(find.text('Technical Specs'), findsNothing);
    expect(find.text('Application Guide'), findsNothing);
    expect(find.textContaining('1.5 - 2.0 ml / gm per liter of water'), findsNothing);

    // Verify parsed HTML description contents
    expect(find.textContaining('Acetobacter fixes atmospheric nitrogen in sugarcane'), findsOneWidget);
    expect(find.text('Key Benefits'), findsOneWidget);
    expect(find.text('High yield enhancement'), findsOneWidget);
    expect(find.text('Soil microbial boost'), findsOneWidget);

    // Verify authentic specifications table
    expect(find.text('Product Specifications & Details'), findsOneWidget);
    expect(find.text('Active Ingredient / Formula'), findsOneWidget);
    expect(find.text('Acetobacter 5x10^8 CFU/ml'), findsWidgets);
    expect(find.text('SKU Code'), findsOneWidget);
    expect(find.text('SKU-ACT-1L'), findsOneWidget);
    expect(find.text('HSN Code'), findsOneWidget);
    expect(find.text('31010099'), findsOneWidget);
  });

  testWidgets('Mobile view header uses single clean menu bar with drawer and no duplicate category bar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SellerWebsiteApp());
    await tester.pumpAndSettle();

    // Verify duplicate CategoryRibbon is NOT rendered on mobile
    expect(find.byType(CategoryRibbon), findsNothing);

    // Verify hamburger icon exists in the top header
    final menuIconBtn = find.byTooltip('Categories Menu');
    expect(menuIconBtn, findsOneWidget);

    // Tap hamburger menu icon to open navigation drawer
    await tester.tap(menuIconBtn);
    await tester.pumpAndSettle();

    // Verify drawer opened with compact quick actions and categories
    expect(find.descendant(of: find.byType(Drawer), matching: find.text('Orders')), findsOneWidget);
    expect(find.descendant(of: find.byType(Drawer), matching: find.text('Wishlist')), findsOneWidget);
    expect(find.descendant(of: find.byType(Drawer), matching: find.text('Technical')), findsOneWidget);
    expect(find.descendant(of: find.byType(Drawer), matching: find.text('Profile')), findsOneWidget);
    expect(find.text('CATEGORIES'), findsOneWidget);
    expect(find.descendant(of: find.byType(Drawer), matching: find.text('All Products')), findsOneWidget);
    final drawerSeeds = find.descendant(of: find.byType(Drawer), matching: find.text('Seeds'));
    expect(drawerSeeds, findsOneWidget);

    // Close drawer
    await tester.tap(find.byTooltip('Close Menu'));
    await tester.pumpAndSettle();

    // Reopen drawer via hamburger icon
    await tester.tap(menuIconBtn);
    await tester.pumpAndSettle();
    expect(find.text('CATEGORIES'), findsOneWidget);

    // Tap 'Seeds' in the drawer
    await tester.tap(drawerSeeds);
    await tester.pumpAndSettle();

    // Tap 'All in Seeds'
    await tester.tap(find.text('All in Seeds'));
    await tester.pumpAndSettle();

    // Verify CategoryDetailView opens instead of applying filter on home screen
    expect(find.byType(CategoryDetailView), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);
    expect(find.text('Featured'), findsOneWidget);

    // Tap 'Back to Home' to return to home page
    await tester.tap(find.text('Back to Home'));
    await tester.pumpAndSettle();

    // Verify back on home page with Best Sellers
    expect(find.byType(HomeView), findsOneWidget);
    expect(find.text('Best Sellers'), findsWidgets);
  });

  testWidgets('CategoryRibbon renders cleanly on narrow mobile screen without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CategoryRibbon(
            selectedCategoryId: 'insecticides',
            selectedSubcategory: 'Systemic Insecticides',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Insecticides'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('FarmerProfileView allows filling personal details and farm delivery address', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Set a verified user
    AuthController.instance.setUserForTest(
      const UserModel(
        phoneNumber: '9876543210',
        name: 'Ramesh Singh',
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: FarmerProfileView(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify sections and fields
    expect(find.text('Farmer Profile & Delivery Address'), findsWidgets);
    expect(find.text('Personal & Contact Details'), findsOneWidget);
    expect(find.text('Farm Depot & Delivery Address'), findsOneWidget);
    expect(find.text('Farm Land & Crop Cultivation (Optional)'), findsOneWidget);
    expect(find.text('Live Parcel Dispatch Preview'), findsOneWidget);

    // Verify verified phone is displayed
    expect(find.textContaining('98765'), findsWidgets);

    // Find and enter name
    final nameField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText?.contains('Ramesh') == true);
    expect(nameField, findsOneWidget);
    await tester.enterText(nameField, 'Sardar Gurpreet Singh');

    // Find and enter Address Line 1
    final address1Field = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText?.contains('Farm Depot 14') == true);
    expect(address1Field, findsOneWidget);
    await tester.enterText(address1Field, 'Khasra No. 42/1, GT Road Farm Depot');

    // Find and enter Village
    final villageField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText?.contains('Nilokheri') == true);
    expect(villageField, findsOneWidget);
    await tester.enterText(villageField, 'Kotli Surat Malhi');

    // Find and enter Taluka
    final talukaField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText?.contains('Karnal Tehsil') == true);
    expect(talukaField, findsOneWidget);
    await tester.enterText(talukaField, 'Batala');

    // Find and enter District
    final districtField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText == 'e.g. Karnal');
    expect(districtField, findsOneWidget);
    await tester.enterText(districtField, 'Gurdaspur');

    // Find and enter PIN
    final pinField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText?.contains('132001') == true);
    expect(pinField, findsOneWidget);
    await tester.enterText(pinField, '143505');

    await tester.pump();

    // Verify live preview updates dynamically
    expect(find.textContaining('Sardar Gurpreet Singh'), findsWidgets);
    expect(find.textContaining('Kotli Surat Malhi'), findsWidgets);
    expect(find.textContaining('143505'), findsWidgets);

    // Tap Save button
    final saveBtn = find.widgetWithText(ElevatedButton, 'Save Profile & Delivery Address');
    expect(saveBtn, findsOneWidget);
    await tester.ensureVisible(saveBtn);
    await tester.pumpAndSettle();
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    // Verify updated UserModel in AuthController
    final updated = AuthController.instance.currentUser;
    expect(updated?.name, 'Sardar Gurpreet Singh');
    expect(updated?.villageOrTown, 'Kotli Surat Malhi');
    expect(updated?.talukaOrTehsil, 'Batala');
    expect(updated?.district, 'Gurdaspur');
    expect(updated?.pinCode, '143505');
  });

  testWidgets('FarmerProfileView renders without overflow on narrow mobile screens (320px)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    AuthController.instance.setUserForTest(
      const UserModel(
        phoneNumber: '9876543210',
        name: 'Ramesh Singh',
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: FarmerProfileView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Farmer Profile & Delivery Address'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MyOrdersView renders order cards, search, status filters, and live tracking stepper', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    OrdersController.instance.resetForTest();

    await tester.pumpWidget(
      const MaterialApp(
        home: MyOrdersView(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header and title
    expect(find.text('My Orders & Farm Deliveries'), findsOneWidget);

    // Verify filter chips
    expect(find.textContaining('All Orders'), findsOneWidget);
    expect(find.textContaining('In Transit & Active'), findsOneWidget);
    expect(find.textContaining('Delivered ('), findsOneWidget);

    // Verify sample orders are rendered
    expect(find.textContaining('EBS-2026-89412'), findsWidgets);
    expect(find.textContaining('AgriLogistics'), findsWidgets);

    // Filter by Delivered
    await tester.tap(find.textContaining('Delivered ('));
    await tester.pumpAndSettle();

    // Verify only delivered order is shown
    expect(find.textContaining('EBS-2026-76120'), findsWidgets);

    // Filter back to All Orders
    await tester.tap(find.textContaining('All Orders'));
    await tester.pumpAndSettle();

    // Search by product name or order ID
    await tester.enterText(find.byType(TextField).first, 'EBS-2026-76120');
    await tester.pumpAndSettle();
    expect(find.textContaining('EBS-2026-76120'), findsWidgets);

    // Clear search
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();

    // Verify no uncaught exceptions
    expect(tester.takeException(), isNull);
  });

  testWidgets('MyOrdersView renders without overflow on narrow mobile screens (320px)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    OrdersController.instance.resetForTest();

    await tester.pumpWidget(
      const MaterialApp(
        home: MyOrdersView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Orders & Farm Deliveries'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MyOrdersView pins filter bar when scrolling and renders compact mobile layout', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    OrdersController.instance.resetForTest();

    await tester.pumpWidget(
      const MaterialApp(
        home: MyOrdersView(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial presence of filter chips and search bar
    expect(find.textContaining('All Orders'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);

    // Scroll down 400 pixels
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();

    // Filter chips and search bar must STILL be visible (pinned, not scrolled away!)
    expect(find.textContaining('All Orders'), findsOneWidget);
    expect(find.textContaining('In Transit & Active'), findsOneWidget);
    expect(find.textContaining('Search Order ID'), findsOneWidget);

    // Can still interact with pinned filter while scrolled
    await tester.tap(find.textContaining('All Orders'));
    await tester.pumpAndSettle();

    expect(find.textContaining('EBS-2026-89412'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Compact order card in MyOrdersView navigates to OrderDetailView and can navigate back', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    OrdersController.instance.resetForTest();

    await tester.pumpWidget(
      const MaterialApp(
        home: MyOrdersView(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify compact view button
    final viewDetailsBtn = find.text('View Order Details').first;
    expect(viewDetailsBtn, findsOneWidget);

    // Tap to open OrderDetailView
    await tester.tap(viewDetailsBtn);
    await tester.pumpAndSettle();

    // Verify we are on OrderDetailView
    expect(find.text('Back to My Orders'), findsOneWidget);
    expect(find.textContaining('Order Details #EBS-2026-89412'), findsOneWidget);
    expect(find.textContaining('Live Courier Shipment Tracking'), findsOneWidget);
    expect(find.textContaining('Ordered Products'), findsOneWidget);
    expect(find.textContaining('Farm Delivery Depot Address'), findsOneWidget);
    expect(find.textContaining('Payment Details'), findsOneWidget);

    // Tap back button
    await tester.tap(find.text('Back to My Orders'));
    await tester.pumpAndSettle();

    // Verify back on MyOrdersView
    expect(find.text('My Orders & Farm Deliveries'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('OrderDetailView renders without overflow on narrow mobile screens (320px)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final order = OrderModel.sampleOrders.first;

    await tester.pumpWidget(
      MaterialApp(
        home: OrderDetailView(order: order),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Back to My Orders'), findsOneWidget);
    expect(find.textContaining('Live Courier Shipment Tracking'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sign out confirmation popup in AuthModal and responsiveness on narrow screens', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    AuthController.instance.setUserForTest(
      const UserModel(
        phoneNumber: '9876543210',
        name: 'Ramesh Singh',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showSignOutConfirmationDialog(context),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap to open sign out confirmation popup
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify confirmation popup widgets
    expect(find.text('Sign Out from BioCrop?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Yes, Sign Out'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Sign Out from BioCrop?'), findsNothing);
  });

  testWidgets('WebFooter renders responsive trust cards without horizontal overflow and displays Facebook, Instagram, YouTube icons', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: WebFooter(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify all 4 trust cards are rendered
    expect(find.text('Guaranteed Authentic Value'), findsOneWidget);
    expect(find.text('FREE Pan-India Shipping'), findsOneWidget);
    expect(find.text('CERTIFIED Lab Quality'), findsOneWidget);
    expect(find.text('EASY Returns & Advisory'), findsOneWidget);

    // Verify social media labels & widgets are rendered
    expect(find.text('Connect With Us:'), findsOneWidget);
    expect(find.byType(SocialIconButton), findsWidgets);

    // Verify Facebook, Instagram, and YouTube icons exist exactly once (only 1 at the top, not repeated)
    expect(find.byTooltip('Follow BioCrop on Facebook'), findsOneWidget);
    expect(find.byTooltip('Follow BioCrop on Instagram'), findsOneWidget);
    expect(find.byTooltip('Subscribe to BioCrop on YouTube'), findsOneWidget);

    // Scroll to Facebook icon, tap and verify feedback snackbar
    final fbIcon = find.byTooltip('Follow BioCrop on Facebook').first;
    await tester.ensureVisible(fbIcon);
    await tester.pumpAndSettle();
    await tester.tap(fbIcon);
    await tester.pumpAndSettle();
    expect(find.text('Opening Facebook...'), findsOneWidget);

    // Verify zero rendering exceptions / overflows on 320px screen
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProductCard renders heart icon and toggles wishlist state', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    WishlistController.instance.clear();
    final testProduct = ProductItem.sampleProducts.first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 260,
            height: 380,
            child: ProductCard(product: testProduct),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify unliked heart icon is rendered initially
    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
    expect(WishlistController.instance.isLiked(testProduct.id), isFalse);

    // Tap heart icon to add to wishlist
    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    await tester.pumpAndSettle();

    // Verify product is now liked
    expect(WishlistController.instance.isLiked(testProduct.id), isTrue);
    expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
    expect(find.textContaining('Added'), findsOneWidget);

    // Tap again to remove
    await tester.tap(find.byIcon(Icons.favorite_rounded).first);
    await tester.pumpAndSettle();

    expect(WishlistController.instance.isLiked(testProduct.id), isFalse);
    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
  });

  testWidgets('Top bar navigation header displays Wishlist button with live count', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    WishlistController.instance.clear();

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MainNavHeader(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Wishlist action exists in desktop header
    expect(find.text('Wishlist'), findsOneWidget);

    // Add a product to wishlist and verify badge updates
    WishlistController.instance.add(ProductItem.sampleProducts.first);
    await tester.pumpAndSettle();

    expect(find.text('1'), findsWidgets);
  });

  testWidgets('WishlistView renders empty state, product items, add to cart and is responsive', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Test 1: Empty state
    WishlistController.instance.clear();

    await tester.pumpWidget(
      const MaterialApp(
        home: WishlistView(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Wishlist'), findsWidgets);
    expect(find.text('Your Wishlist is Empty'), findsOneWidget);
    expect(find.text('Explore Store'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Test 2: Populated wishlist with products
    WishlistController.instance.add(ProductItem.sampleProducts[0]);
    WishlistController.instance.add(ProductItem.sampleProducts[1]);
    await tester.pumpAndSettle();

    expect(find.text('2 products saved'), findsOneWidget);
    expect(find.text('Add to Cart'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Category click on Home opens dedicated CategoryDetailView instead of home filter', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SellerWebsiteApp());
    await tester.pumpAndSettle();

    // Verify on home screen
    expect(find.byType(HomeView), findsOneWidget);
    expect(find.text('Best Sellers'), findsWidgets);

    // Click on 'Crop Protection' tab in category ribbon
    final cropProtectionTab = find.text('Crop Protection').first;
    await tester.tap(cropProtectionTab);
    await tester.pumpAndSettle();

    // Verify CategoryDetailView opened instead of applying filter on home screen
    expect(find.byType(CategoryDetailView), findsOneWidget);
    expect(find.text('Crop Protection'), findsWidgets);
    expect(find.text('Back to Home'), findsOneWidget);
    expect(find.text('All in Crop Protection'), findsOneWidget);

    // Verify all category group pills wrap cleanly on desktop and are not cut off
    expect(find.text('Combo Product'), findsOneWidget);
    final comboRight = tester.getTopRight(find.text('Combo Product')).dx;
    expect(comboRight < 1440.0, isTrue, reason: 'Combo Product pill must not be cut off at screen edge');

    // Tap on 'Bio Pesticides' group to reveal its Level 2 subcategories
    await tester.tap(find.text('Bio Pesticides').first);
    await tester.pumpAndSettle();

    // Verify subcategories show up, but 'All in Category' is removed
    expect(find.text('Subcategories: '), findsOneWidget);
    expect(find.text('All in Category'), findsNothing);
    expect(find.text('Bio Insecticide'), findsOneWidget);

    // Enter a search that yields 0 products to trigger empty state with 'Reset All Filters'
    final searchInput = find.byType(TextField);
    if (searchInput.evaluate().isNotEmpty) {
      await tester.enterText(searchInput.first, 'XYZNonExistentProductQuery');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(find.text('Reset All Filters'), findsOneWidget);
      await tester.tap(find.text('Reset All Filters'));
      await tester.pumpAndSettle();

      // Verify it resets to "All in that major category" (All in Crop Protection)
      expect(find.text('All in Crop Protection'), findsOneWidget);
    }

    // Tap 'Back to Home'
    await tester.tap(find.text('Back to Home'));
    await tester.pumpAndSettle();

    // Verify back on home screen
    expect(find.byType(HomeView), findsOneWidget);
    expect(find.text('Best Sellers'), findsWidgets);
  });

  testWidgets('CategoryDetailView mobile view renders compact top bar with back button and filter button without major or sub category bars', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: CategoryDetailView(
          initialCategoryId: 'crop-protection',
          initialSubcategory: 'Insecticides',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify CategoryDetailView is rendered
    expect(find.byType(CategoryDetailView), findsOneWidget);

    // Verify top bar with back button and filter button
    expect(find.text('Back to Home'), findsOneWidget);
    expect(find.text('Featured'), findsOneWidget);

    // Verify categories in this major category are rendered on mobile ('All' instead of 'All in ...')
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Insecticides'), findsWidgets);
    expect(find.text('Fungicides'), findsWidgets);

    // Verify subcategory row is NOT rendered on mobile
    expect(find.text('Subcategories: '), findsNothing);
    expect(find.text('Systemic Insecticides'), findsNothing);

    // Switch to narrow screen (320px) to verify no overflow on small phones
    tester.view.physicalSize = const Size(320, 568);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('CategoryDetailView handles initial 1x1 constraint layout pass without RenderFlex overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1, 1);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: CategoryDetailView(
          initialCategoryId: 'crop-protection',
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('CategoryController.fetchCategories parses 3-tier hierarchy from GET /api/v1/categories and updates HomeView & CategoryRibbon', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(CategoryController.instance.resetToSampleCategories);

    final mockClient = MockClient((http.Request request) async {
      expect(request.url.path, equals('/api/v1/categories'));
      final payload = {
        'success': true,
        'message': 'Categories retrieved successfully',
        'data': {
          'content': [
            {
              'id': '6ab4f6f619ec643fd9bf362c',
              'name': 'Crop Protection',
              'slug': 'crop-protection',
              'parentId': null,
              'level': 0,
              'sortOrder': 1,
              'isActive': true,
            },
            {
              'id': '6ab4f6f619ec643fd9bf3689',
              'name': 'Seeds',
              'slug': 'seeds',
              'parentId': null,
              'level': 0,
              'sortOrder': 2,
              'isActive': true,
            },
            {
              'id': '6ab4f6f619ec643fd9bf3620',
              'name': 'Insecticides',
              'slug': 'insecticides',
              'parentId': '6ab4f6f619ec643fd9bf362c',
              'level': 1,
              'sortOrder': 1,
              'isActive': true,
            },
            {
              'id': '6ab4f6f619ec643fd9bf366a',
              'name': 'Bio Pesticides',
              'slug': 'bio-pesticides',
              'parentId': '6ab4f6f619ec643fd9bf362c',
              'level': 1,
              'sortOrder': 2,
              'isActive': true,
            },
            {
              'id': '6ab4f6f619ec643fd9bf366b',
              'name': 'Bio Insecticide',
              'slug': 'bio-insecticide',
              'parentId': '6ab4f6f619ec643fd9bf366a',
              'level': 2,
              'sortOrder': 1,
              'isActive': true,
            },
            {
              'id': '6ab4f6f619ec643fd9bf366c',
              'name': 'Bio Fungicide',
              'slug': 'bio-fungicide',
              'parentId': '6ab4f6f619ec643fd9bf366a',
              'level': 1 + 1,
              'sortOrder': 2,
              'isActive': true,
            },
          ],
          'page': 0,
          'size': 6,
          'totalElements': 6,
          'totalPages': 1,
          'first': true,
          'last': true,
        },
      };
      return http.Response(jsonEncode(payload), 200);
    });

    await CategoryController.instance.fetchCategories(
      client: mockClient,
      forceRefresh: true,
    );

    expect(CategoryController.instance.hasLoadedFromApi, isTrue);
    expect(CategoryController.instance.categories.length, equals(2));
    expect(CategoryController.instance.categories.first.name, equals('Crop Protection'));
    expect(CategoryController.instance.categories.first.backendId, equals('6ab4f6f619ec643fd9bf362c'));
    expect(CategoryController.instance.categories.first.groups.length, equals(2));
    expect(CategoryController.instance.categories.first.groups[1].name, equals('Bio Pesticides'));
    expect(
      CategoryController.instance.categories.first.groups[1].subcategories,
      equals(['Bio Insecticide', 'Bio Fungicide']),
    );

    await tester.pumpWidget(const SellerWebsiteApp());
    await tester.pumpAndSettle();

    expect(find.text('Crop Protection'), findsWidgets);
    expect(find.text('Seeds'), findsWidgets);
  });

  testWidgets('CategoryBloc fetches categories via CategoryRepository and reacts to WebSocket categories:* events', (WidgetTester tester) async {
    addTearDown(CategoryController.instance.resetToSampleCategories);

    int fetchCount = 0;
    final mockClient = MockClient((http.Request request) async {
      fetchCount++;
      final isSecondFetch = fetchCount >= 2;
      final payload = {
        'success': true,
        'message': 'Categories retrieved successfully',
        'data': {
          'content': [
            {
              'id': '6ab4f6f619ec643fd9bf362c',
              'name': 'Crop Protection',
              'slug': 'crop-protection',
              'parentId': null,
              'level': 0,
              'sortOrder': 1,
              'isActive': true,
            },
            if (isSecondFetch)
              {
                'id': '6ab4f6f619ec643fd9bf3735',
                'name': 'Gardening',
                'slug': 'gardening',
                'parentId': null,
                'level': 0,
                'sortOrder': 2,
                'isActive': true,
              },
          ],
          'page': 0,
          'size': 2,
          'totalElements': isSecondFetch ? 2 : 1,
          'totalPages': 1,
          'first': true,
          'last': true,
        },
      };
      return http.Response(jsonEncode(payload), 200);
    });

    final apiClient = ApiClient(client: mockClient);
    final remoteDataSource = CategoryRemoteDataSourceImpl(apiClient);
    final repository = CategoryRepositoryImpl(remoteDataSource: remoteDataSource);
    final wsService = WebSocketService();
    final bloc = CategoryBloc(
      categoryRepository: repository,
      webSocketService: wsService,
    );
    addTearDown(bloc.close);

    // 1. Trigger FetchCategories event on CategoryBloc
    bloc.add(const FetchCategories(isRefresh: true));
    await tester.pumpAndSettle();

    expect(fetchCount, equals(1));
    expect(bloc.state.categories.length, equals(1));
    expect(bloc.state.categories.first.name, equals('Crop Protection'));

    // 2. Simulate real-time WebSocket event `categories:created` from backend
    wsService.handleRawMessageForTest(
      jsonEncode({
        'event': 'categories:created',
        'data': {'id': '6ab4f6f619ec643fd9bf3735', 'name': 'Gardening'},
      }),
    );
    await tester.pumpAndSettle();

    expect(fetchCount, equals(2));
    expect(bloc.state.categories.length, equals(2));
    expect(bloc.state.categories[1].name, equals('Gardening'));
  });

  testWidgets('ProductBloc fetches public products without auth, maps Level 1/2 categoryIds to Level 0 categories on HomeView, and reacts to WebSocket products:* events', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(CategoryController.instance.resetToSampleCategories);
    addTearDown(ProductController.instance.resetToSampleProducts);

    // 1. Seed a 3-tier category hierarchy (Crop Protection -> Insecticides, Seeds -> Vegetable Seeds -> Tomato Seeds)
    final categories = CategoryController.buildCategoryHierarchy([
      const ApiCategoryRecord(
        id: '6ab4f6f619ec643fd9bf362c',
        name: 'Crop Protection',
        slug: 'crop-protection',
        parentId: null,
        level: 0,
        sortOrder: 1,
        isActive: true,
      ),
      const ApiCategoryRecord(
        id: '6ab4f6f619ec643fd9bf3620',
        name: 'Insecticides',
        slug: 'insecticides',
        parentId: '6ab4f6f619ec643fd9bf362c',
        level: 1,
        sortOrder: 1,
        isActive: true,
      ),
      const ApiCategoryRecord(
        id: '6ab4f6f619ec643fd9bf3689',
        name: 'Seeds',
        slug: 'seeds',
        parentId: null,
        level: 0,
        sortOrder: 2,
        isActive: true,
      ),
      const ApiCategoryRecord(
        id: '6ab4f6f619ec643fd9bf368a',
        name: 'Vegetable Seeds',
        slug: 'vegetable-seeds',
        parentId: '6ab4f6f619ec643fd9bf3689',
        level: 1,
        sortOrder: 1,
        isActive: true,
      ),
      const ApiCategoryRecord(
        id: '6ab4f6f619ec643fd9bf368b',
        name: 'Tomato Seeds',
        slug: 'tomato-seeds',
        parentId: '6ab4f6f619ec643fd9bf368a',
        level: 2,
        sortOrder: 1,
        isActive: true,
      ),
    ]);
    CategoryController.instance.syncFromBloc(categories);

    int productFetchCount = 0;
    final mockClient = MockClient((http.Request request) async {
      productFetchCount++;
      // Verify no Authorization header is required for public products API
      expect(request.headers.containsKey('Authorization'), isFalse);
      expect(request.url.path, equals('/api/v1/products'));

      final payload = {
        'success': true,
        'message': 'Products retrieved successfully',
        'data': {
          'content': [
            {
              'id': 'prod_live_1',
              'title': 'Pralaya Super Cypermethrin 25% EC',
              'technicalName': 'Cypermethrin 25% EC',
              'sellerName': 'essentialbiocropscience',
              // Assigned to Level 1 category `Insecticides` under `Crop Protection`
              'categoryId': '6ab4f6f619ec643fd9bf3620',
              'isAvailable': true,
              'isFeatured': true,
              'productImages': [
                {
                  'id': 'img1',
                  'displayOrder': 0,
                  'midUrl': 'https://dujjhct8zer0r.cloudfront.net/images/prod_image/katyayani-all-in-one.webp',
                },
              ],
              'variants': [
                {
                  'id': 'v_live_1',
                  'label': '1 Ltr',
                  'displayRate': productFetchCount >= 2 ? 490.0 : 510.0,
                  'printedMrp': 1200.0,
                  'stock': 100,
                  'isDefault': true,
                },
              ],
            },
            {
              'id': 'prod_live_2',
              'title': 'EBS Hybrid Arka Rakshak Tomato Seeds',
              'technicalName': 'F1 Hybrid Tomato Seeds',
              'sellerName': 'essentialbiocropscience',
              // Assigned to Level 2 nested category `Tomato Seeds` under `Seeds -> Vegetable Seeds`
              'categoryId': '6ab4f6f619ec643fd9bf368b',
              'isAvailable': true,
              'isFeatured': false,
              'variants': [
                {
                  'id': 'v_live_2',
                  'label': '10 gm',
                  'displayRate': 620.0,
                  'printedMrp': 850.0,
                  'stock': 50,
                  'isDefault': true,
                },
              ],
            },
          ],
          'page': 0,
          'size': 500,
          'totalElements': 2,
          'totalPages': 1,
          'first': true,
          'last': true,
        },
      };
      return http.Response(jsonEncode(payload), 200);
    });

    final apiClient = ApiClient(client: mockClient);
    final productRemote = ProductRemoteDataSourceImpl(apiClient);
    final productRepo = ProductRepositoryImpl(remoteDataSource: productRemote);
    final wsService = WebSocketService();

    // 2. Pump SellerWebsiteApp with our injected ProductRepository
    await tester.pumpWidget(
      SellerWebsiteApp(productRepository: productRepo),
    );
    await tester.pumpAndSettle();

    final homeContext = tester.element(find.byType(HomeView));
    final productBloc = BlocProvider.of<ProductBloc>(homeContext);

    // 3. Trigger FetchProducts via ProductBloc and verify public API fetch without auth
    final firstLoad = productBloc.stream.first;
    productBloc.add(const FetchProducts(isRefresh: true));
    await firstLoad;
    await tester.pumpAndSettle();

    expect(productFetchCount, equals(1));
    expect(productBloc.state.products.length, equals(2));
    expect(productBloc.state.products[0].rootCategoryId, equals('crop-protection'));
    expect(productBloc.state.products[1].rootCategoryId, equals('seeds'));

    // 4. Verify Level 0 category sections are rendered one by one on HomeView with their products
    expect(find.byKey(const ValueKey('home_level0_section_crop-protection')), findsOneWidget);
    expect(find.byKey(const ValueKey('home_level0_section_seeds')), findsOneWidget);
    expect(find.text('Pralaya Super Cypermethrin 25% EC'), findsWidgets);
    expect(find.text('EBS Hybrid Arka Rakshak Tomato Seeds'), findsWidgets);

    // 5. Simulate real-time WebSocket `products:updated` event and verify automatic refresh
    final wsReload = productBloc.stream.first;
    wsService.handleRawMessageForTest(
      jsonEncode({
        'event': 'products:updated',
        'data': {'id': 'prod_live_1'},
      }),
    );
    await wsReload;
    await tester.pumpAndSettle();

    expect(productFetchCount, equals(2));
    expect(productBloc.state.products.first.displayRate, equals(490.0));

    // 6. Verify backend categories have no static emoji icons and ProductCard renders AppProductImage
    expect(categories.first.icon, isEmpty);
    expect(categories.first.groups.first.icon, isNull);
    expect(find.byType(AppProductImage), findsWidgets);
  });
}



