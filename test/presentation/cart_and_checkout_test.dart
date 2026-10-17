import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seller_website/data/models/product_model.dart';
import 'package:seller_website/logic/cart/cart_bloc.dart';
import 'package:seller_website/logic/cart/cart_event.dart';
import 'package:seller_website/presentation/home/widgets/cart_drawer.dart';
import 'package:seller_website/presentation/home/widgets/farmer_checkout_modal.dart';

void main() {
  const sampleProduct = ProductModel(
    id: 'ebs-bio-npk-01',
    title: 'EBS Bio-NPK Liquid Consortium',
    hindiTitle: 'ईबीएस बायो-एनपीके कंसोर्टियम',
    brand: 'EBS BioCrop Science',
    category: 'Bio-Fertilizers & Organics',
    technicalName: 'Azotobacter + PSB + KMB Consortia',
    hindiTechnical: 'एजोटोबैक्टर + पीएसबी + केएमबी',
    imageUrl: 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?q=80&w=600&auto=format&fit=crop',
    suitableCrops: 'Cotton, Soybean, Wheat',
    targetPests: 'Root growth and nitrogen fixation',
    dosage: '250 ml / acre',
    variants: [
      PackVariant(id: 'v1', label: '1 Litre Bottle', mrp: 650, sellingPrice: 420, stock: 50),
    ],
  );

  testWidgets('CartDrawer displays empty state and when populated displays item with checkout button',
      (WidgetTester tester) async {
    final cartBloc = CartBloc();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cartBloc,
          child: const Scaffold(
            endDrawer: CartDrawer(),
            body: Center(child: Text('Home Content')),
          ),
        ),
      ),
    );

    // Open Drawer
    final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
    scaffoldState.openEndDrawer();
    await tester.pumpAndSettle();

    // Verify empty state text
    expect(find.textContaining('आपकी टोकरी खाली है'), findsOneWidget);

    // Add item to cart
    cartBloc.add(AddToCart(product: sampleProduct, variant: sampleProduct.variants.first, quantity: 2));
    await tester.pumpAndSettle();

    // Verify item title and total price
    expect(find.text('EBS Bio-NPK Liquid Consortium'), findsOneWidget);
    expect(find.text('Pack: 1 Litre Bottle'), findsOneWidget);
    expect(find.text('₹840'), findsWidgets); // 420 * 2 = 840
    expect(find.textContaining('Proceed to Farmer Checkout'), findsOneWidget);
  });

  testWidgets('FarmerCheckoutModal renders form fields and places order successfully', (WidgetTester tester) async {
    final cartBloc = CartBloc();
    cartBloc.add(AddToCart(product: sampleProduct, variant: sampleProduct.variants.first, quantity: 1));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: cartBloc,
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => FarmerCheckoutModal.show(context, cartBloc.state),
                child: const Text('Open Checkout'),
              );
            },
          ),
        ),
      ),
    );

    // Open modal
    await tester.tap(find.text('Open Checkout'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Farmer Checkout'), findsOneWidget);
    expect(find.textContaining('Cash on Delivery'), findsOneWidget);
    expect(find.textContaining('Farmer Full Name'), findsOneWidget);

    // Fill form
    await tester.enterText(find.byType(TextFormField).at(0), 'Ramesh Patel');
    await tester.enterText(find.byType(TextFormField).at(1), '9876543210');
    await tester.enterText(find.byType(TextFormField).at(2), 'Anandpur Gaon');
    await tester.enterText(find.byType(TextFormField).at(4), 'Nashik');
    await tester.enterText(find.byType(TextFormField).at(5), '422001');

    // Tap Confirm Order
    await tester.tap(find.textContaining('Confirm Order'));
    await tester.pumpAndSettle();

    // Verify Success screen
    expect(find.textContaining('Order Placed Successfully'), findsOneWidget);
    expect(find.textContaining('बधाई हो Ramesh Patel जी'), findsOneWidget);
    expect(find.textContaining('EBS-OD-'), findsOneWidget);
  });
}
