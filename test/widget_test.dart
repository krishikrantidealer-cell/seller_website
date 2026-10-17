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
  });
}
