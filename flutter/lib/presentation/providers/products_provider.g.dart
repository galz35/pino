// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'products_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$productsHash() => r'464a4d9d3fc48234489b596d61f4c5b6c5e427fb';

/// See also [products].
@ProviderFor(products)
final productsProvider = AutoDisposeFutureProvider<List<Product>>.internal(
  products,
  name: r'productsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$productsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProductsRef = AutoDisposeFutureProviderRef<List<Product>>;
String _$filteredProductsHash() => r'6f8c0edfed47deb56cf86826e9906f6143ccffe8';

/// See also [filteredProducts].
@ProviderFor(filteredProducts)
final filteredProductsProvider =
    AutoDisposeFutureProvider<List<Product>>.internal(
      filteredProducts,
      name: r'filteredProductsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$filteredProductsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredProductsRef = AutoDisposeFutureProviderRef<List<Product>>;
String _$productSearchQueryHash() =>
    r'1d109b45d1ef45b542b7be1dac94192c24694d44';

/// See also [ProductSearchQuery].
@ProviderFor(ProductSearchQuery)
final productSearchQueryProvider =
    AutoDisposeNotifierProvider<ProductSearchQuery, String>.internal(
      ProductSearchQuery.new,
      name: r'productSearchQueryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$productSearchQueryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProductSearchQuery = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
