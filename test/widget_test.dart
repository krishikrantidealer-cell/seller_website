import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seller_website/data/models/catalog_models.dart';
import 'package:seller_website/main.dart';
import 'package:seller_website/presentation/product_detail/product_detail_view.dart';
import 'package:seller_website/data/models/auth_state.dart';
import 'package:seller_website/presentation/profile/farmer_profile_view.dart';
import 'package:seller_website/presentation/widgets/category_ribbon.dart';
import 'package:seller_website/presentation/widgets/product_card.dart';
import 'package:seller_website/data/models/order_models.dart';
import 'package:seller_website/presentation/orders/my_orders_view.dart';
import 'package:seller_website/presentation/widgets/auth_modal.dart';
import 'package:seller_website/presentation/widgets/web_footer.dart';
import 'package:seller_website/presentation/technical/technical_search_view.dart';

void main() {
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
    expect(find.text('Best Sellers'), findsWidgets);
    expect(find.textContaining('8 Best Sellers'), findsWidgets);
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
    expect(find.text('Hybrid Tomato Seeds'), findsNothing);

    // Now hover over "Vegetable Seeds"
    final vegSeeds = find.text('Vegetable Seeds').first;
    await gesture.moveTo(tester.getCenter(vegSeeds));
    await tester.pumpAndSettle();

    // Verify subcategories in the side panel opened for Vegetable Seeds
    expect(find.text('Hybrid Tomato Seeds'), findsOneWidget);

    // Now hover over "Field Crop Seeds"
    final fieldCrops = find.text('Field Crop Seeds').first;
    await gesture.moveTo(tester.getCenter(fieldCrops));
    await tester.pumpAndSettle();

    // Verify subcategories in the side updated to Field Crops subcategories
    expect(find.text('Hybrid Paddy (Rice) Seeds'), findsOneWidget);

    // Click subcategory "Hybrid Paddy (Rice) Seeds"
    await tester.tap(find.text('Hybrid Paddy (Rice) Seeds'));
    await tester.pumpAndSettle();

    // Should filter by subcategory
    expect(find.textContaining('Paddy'), findsWidgets);
  });

  testWidgets('All 11 AgriBegri Major Categories are rendered and support cascaded 2-stage hover', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CategoryRibbon(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify all 11 AgriBegri major category names exist in the data model
    final expected11Categories = [
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
    ];

    expect(CategoryItem.sampleCategories.length, equals(11));
    for (final catName in expected11Categories) {
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
    expect(find.text('Systemic Insecticides'), findsNothing);

    // Hover over 'Insecticides' category
    final insecticidesCategory = find.text('Insecticides').first;
    await gesture.moveTo(tester.getCenter(insecticidesCategory));
    await tester.pumpAndSettle();

    // Subcategories should now be visible in the side panel
    expect(find.text('Systemic Insecticides'), findsOneWidget);
    expect(find.text('Contact & Ingestion'), findsOneWidget);
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
    final reviewsAccordion = find.text('Farmer Reviews (3)');
    await tester.ensureVisible(reviewsAccordion);
    await tester.tap(reviewsAccordion);
    await tester.pumpAndSettle();

    // Verify reviews content rendered without overflow
    expect(find.text('Write a Review'), findsOneWidget);
    expect(find.textContaining('100% Authenticated field purchases'), findsOneWidget);
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

    // Verify drawer opened with categories
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

    // Verify Seeds category is selected and reflected on home page filter banner
    expect(find.textContaining('Filtered by: Seeds'), findsOneWidget);

    // Verify 'Reset' button appears on the filter banner and tapping it clears the filter
    final resetBtn = find.text('Reset');
    expect(resetBtn, findsOneWidget);
    await tester.tap(resetBtn);
    await tester.pumpAndSettle();

    // Verify reset back - filter banner is gone
    expect(find.textContaining('Filtered by:'), findsNothing);
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
}



