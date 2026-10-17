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
}
