import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seller_website/presentation/widgets/floating_whatsapp_button.dart';
import 'package:seller_website/core/constants/app_constants.dart';

void main() {
  testWidgets('FloatingWhatsAppButton renders with icon and status dot on desktop',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              FloatingWhatsAppButton(),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    // Verify WhatsApp button is rendered in the tree
    expect(find.byType(FloatingWhatsAppButton), findsOneWidget);

    // Verify CustomPaint for the vector WhatsApp icon is present
    expect(find.byType(CustomPaint), findsWidgets);

    // Verify Online green dot is present
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == const Color(0xFF22C55E),
      ),
      findsOneWidget,
    );
  });

  testWidgets('FloatingWhatsAppButton renders properly on mobile viewport',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              FloatingWhatsAppButton(
                phoneNumber: AppConstants.helplineNumber,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(FloatingWhatsAppButton), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
