import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_quota.dart';
import '../services/chat_quota_repository.dart';

final chatQuotaRepositoryProvider = Provider<ChatQuotaRepository>((ref) {
  if (kDebugMode) {
    const override = String.fromEnvironment(
      'VIDE_DEBUG_CHAT_QUOTA',
      defaultValue: 'unknown',
    );
    return DebugChatQuotaRepository.fromOverride(override);
  }
  return const UnknownChatQuotaRepository();
});

final chatQuotaProvider = StreamProvider<ChatQuota>((ref) {
  return ref.watch(chatQuotaRepositoryProvider).watch();
});
