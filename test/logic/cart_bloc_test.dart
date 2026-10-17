import 'package:flutter_test/flutter_test.dart';
import 'package:seller_website/data/repositories/mock_catalog_repository.dart';
import 'package:seller_website/logic/cart/cart_bloc.dart';
import 'package:seller_website/logic/cart/cart_event.dart';

void main() {
  group('CartBloc', () {
    late CartBloc cartBloc;

    setUp(() {
      cartBloc = CartBloc();
    });

    tearDown(() {
      cartBloc.close();
    });

    test('initial state has empty cart', () {
      expect(cartBloc.state.items, isEmpty);
      expect(cartBloc.state.totalCount, 0);
      expect(cartBloc.state.subtotal, 0.0);
    });

    test('AddToCart adds product variant and computes savings', () async {
      final product = MockCatalogRepository.products.first;
      final variant = product.variants.first;

      cartBloc.add(AddToCart(product: product, variant: variant));

      await expectLater(
        cartBloc.stream,
        emits(predicate((state) {
          return cartBloc.state.items.length == 1 &&
              cartBloc.state.totalCount == 1 &&
              cartBloc.state.subtotal == variant.sellingPrice &&
              cartBloc.state.totalSavings > 0;
        })),
      );
    });
  });
}
