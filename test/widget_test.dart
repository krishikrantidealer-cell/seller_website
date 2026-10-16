import 'package:flutter_test/flutter_test.dart';

import 'package:seller_website/main.dart';

void main() {
  testWidgets('SellerWebsiteApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SellerWebsiteApp());

    expect(find.text('Seller Website'), findsOneWidget);
  });
}
