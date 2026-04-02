// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'closing_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todayOrdersHash() => r'fd2fe59ee59b1c3b8b686faf12b1f5ab206007d8';

/// See also [todayOrders].
@ProviderFor(todayOrders)
final todayOrdersProvider = AutoDisposeStreamProvider<List<Order>>.internal(
  todayOrders,
  name: r'todayOrdersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayOrdersRef = AutoDisposeStreamProviderRef<List<Order>>;
String _$todayCollectionsHash() => r'd61dffc3942ee18a875c895b3b2d2b3e0a95e7ef';

/// See also [todayCollections].
@ProviderFor(todayCollections)
final todayCollectionsProvider =
    AutoDisposeStreamProvider<List<CollectionReceipt>>.internal(
      todayCollections,
      name: r'todayCollectionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todayCollectionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayCollectionsRef =
    AutoDisposeStreamProviderRef<List<CollectionReceipt>>;
String _$todaySystemTotalHash() => r'06c6f2a96366526a065ee470f82ffff667ada757';

/// See also [todaySystemTotal].
@ProviderFor(todaySystemTotal)
final todaySystemTotalProvider = AutoDisposeProvider<double>.internal(
  todaySystemTotal,
  name: r'todaySystemTotalProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todaySystemTotalHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodaySystemTotalRef = AutoDisposeProviderRef<double>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
