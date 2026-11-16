import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seller_website/data/services/collection_api_service.dart';
import 'package:seller_website/presentation/collection/collection_detail_view.dart';
import 'package:seller_website/presentation/collection/sub_collection_detail_view.dart';

void main() {
  testWidgets(
      'CollectionDetailView displays all sub-collections and opens SubCollectionDetailView on tap',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final subs = List.generate(
      8,
      (i) => StoreSubCollection(
        id: 'sub-$i',
        name: 'Crop $i',
        slug: 'crop-$i',
      ),
    );
    final collection = StoreCollection(
      id: 'col-1',
      name: 'Shop by Crop',
      slug: 'shop-by-crop',
      description: 'Browse products by crop',
      subCollections: subs,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: CollectionDetailView(collection: collection),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Shop by Crop'), findsWidgets);
    expect(find.text('8 Sub-Collections'), findsOneWidget);
    expect(find.text('Crop 0'), findsOneWidget);
    expect(find.text('Crop 7'), findsOneWidget);

    await tester.tap(find.text('Crop 2'));
    await tester.pumpAndSettle();

    expect(find.byType(SubCollectionDetailView), findsOneWidget);
    expect(find.text('Crop 2'), findsWidgets);
  });
}
