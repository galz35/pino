import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/global_settings.dart';

part 'settings_provider.g.dart';

@riverpod
Future<GlobalSettings> settings(Ref ref) async {
  return ref.watch(settingsRepositoryProvider).getSettings();
}
