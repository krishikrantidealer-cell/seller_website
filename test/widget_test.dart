import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seller_website/main.dart';
import 'package:seller_website/presentation/widgets/product_card.dart';

void main() {
  testWidgets('SellerWebsiteApp smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SellerWebsiteApp());
    await tester.pump();

    expect(find.text('BioCrop'), findsWidgets);
    expect(find.text('Track Order'), findsOneWidget);

    // Verify Add to Cart and Buy Now buttons exist on catalog cards
    final addToCartBtn = find.widgetWithText(ElevatedButton, 'Add to Cart').first;
    expect(addToCartBtn, findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Buy Now'), findsWidgets);

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

    // Verify Dropdown menu is visible with Track Orders and Sign Out
    expect(find.text('Track Orders'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);

    // Tap Sign Out from dropdown
    await tester.tap(find.text('Sign Out'));
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

    // Initial default hovered category is Vegetable Seeds, so its subcategory is visible in side panel
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
    await tester.tap(find.text('View Products'));
    await tester.pumpAndSettle();

    // Verify redirected to products list with technical formulation active
    expect(find.textContaining('Chlorantraniliprole 18.5% SC'), findsWidgets);
    expect(find.text('Katyayani All in One Insecticide for Crops'), findsOneWidget);
  });
}

