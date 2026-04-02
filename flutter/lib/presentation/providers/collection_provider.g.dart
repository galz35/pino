// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$clientsWithDebtHash() => r'bd21fd3b8b634d8e783da514c4699aee5b1b362a';

/// See also [clientsWithDebt].
@ProviderFor(clientsWithDebt)
final clientsWithDebtProvider =
    AutoDisposeFutureProvider<List<Client>>.internal(
      clientsWithDebt,
      name: r'clientsWithDebtProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$clientsWithDebtHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ClientsWithDebtRef = AutoDisposeFutureProviderRef<List<Client>>;
String _$collectionNotifierHash() =>
    r'90dd8252b4c7d716122196615ed27fd04799a802';

/// See also [CollectionNotifier].
@ProviderFor(CollectionNotifier)
final collectionNotifierProvider =
    AutoDisposeAsyncNotifierProvider<CollectionNotifier, void>.internal(
      CollectionNotifier.new,
      name: r'collectionNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$collectionNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CollectionNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
