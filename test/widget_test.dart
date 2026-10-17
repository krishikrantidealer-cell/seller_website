import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seller_website/main.dart';
import 'package:seller_website/presentation/home/widgets/farmer_quick_bar.dart';

void main() {
  testWidgets('SellerWebsiteApp renders farmer portal and quick actions', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() async => await tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const SellerWebsiteApp());
    await tester.pump();

    // Verify Farmer Quick Bar is mounted
    expect(find.byType(FarmerQuickBar), findsOneWidget);
    expect(find.textContaining('1800-203-1425'), findsWidgets);
    expect(find.textContaining('WhatsApp'), findsWidgets);
    expect(find.textContaining('Crop Doctor'), findsWidgets);
  });
}
