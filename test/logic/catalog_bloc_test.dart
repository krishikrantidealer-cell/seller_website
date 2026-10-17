import 'package:flutter_test/flutter_test.dart';
import 'package:seller_website/logic/catalog/catalog_bloc.dart';
import 'package:seller_website/logic/catalog/catalog_event.dart';
import 'package:seller_website/logic/catalog/catalog_state.dart';

void main() {
  group('CatalogBloc', () {
    late CatalogBloc catalogBloc;

    setUp(() {
      catalogBloc = CatalogBloc();
    });

    tearDown(() {
      catalogBloc.close();
    });

    test('initial state has initial status and empty products', () {
      expect(catalogBloc.state.status, CatalogStatus.initial);
      expect(catalogBloc.state.allProducts, isEmpty);
    });

    test('LoadCatalog loads categories and products with EBS BioCrop branding', () async {
      catalogBloc.add(const LoadCatalog());
      await expectLater(
        catalogBloc.stream,
        emitsInOrder([
          predicate<CatalogState>((s) => s.status == CatalogStatus.loading),
          predicate<CatalogState>((s) {
            return s.status == CatalogStatus.loaded &&
                s.allProducts.isNotEmpty &&
                s.categories.isNotEmpty &&
                s.allProducts.every((p) => p.brand.contains('EBS BioCrop'));
          }),
        ]),
      );
    });

    test('SearchTechnicalOrBrand filters catalog correctly', () async {
      catalogBloc.add(const LoadCatalog());
      await catalogBloc.stream.firstWhere((s) => s.status == CatalogStatus.loaded);

      catalogBloc.add(const SearchTechnicalOrBrand('Chlorantraniliprole'));
      final searchedState = await catalogBloc.stream.first;

      expect(searchedState.filteredProducts.isNotEmpty, isTrue);
      expect(searchedState.filteredProducts.first.technicalName, contains('Chlorantraniliprole'));
    });
  });
}
