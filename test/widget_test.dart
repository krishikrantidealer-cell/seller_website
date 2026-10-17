import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seller_website/main.dart';

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

    // Verify User is logged in and header shows logged in user
    expect(find.text('Kisan Farmer'), findsWidgets);
    expect(find.textContaining('98765 43210'), findsWidgets);

    // Tap the account button again to open Profile View
    final loggedInAccount = find.text('Kisan Farmer').first;
    await tester.tap(loggedInAccount);
    await tester.pumpAndSettle();

    // Verify Account Profile menu is visible with Logout button
    expect(find.text('Track My Orders'), findsOneWidget);
    final logoutBtn = find.widgetWithText(OutlinedButton, 'Sign Out / Logout');
    expect(logoutBtn, findsOneWidget);

    // Tap Logout
    await tester.tap(logoutBtn);
    await tester.pumpAndSettle();

    // Verify user is logged out back to Login / My Account
    expect(find.widgetWithText(OutlinedButton, 'Login / My Account'), findsOneWidget);
  });
}

