import '../models/chat_quota.dart';

abstract interface class ChatQuotaRepository {
  Future<ChatQuota> fetch();

  Stream<ChatQuota> watch();
}

class UnknownChatQuotaRepository implements ChatQuotaRepository {
  const UnknownChatQuotaRepository();

  static const _unknownQuota = ChatQuota(remaining: null);

  @override
  Future<ChatQuota> fetch() async => _unknownQuota;

  @override
  Stream<ChatQuota> watch() => Stream<ChatQuota>.value(_unknownQuota);
}

class DebugChatQuotaRepository implements ChatQuotaRepository {
  const DebugChatQuotaRepository(this.quota);

  final ChatQuota quota;

  factory DebugChatQuotaRepository.fromOverride(String value) {
    final remaining = switch (value) {
      'unknown' => null,
      '0' => 0,
      '1' => 1,
      '5' => 5,
      _ => throw FormatException(
        'VIDE_DEBUG_CHAT_QUOTA must be unknown, 0, 1, or 5.',
        value,
      ),
    };
    return DebugChatQuotaRepository(ChatQuota(remaining: remaining));
  }

  @override
  Future<ChatQuota> fetch() async => quota;

  @override
  Stream<ChatQuota> watch() => Stream<ChatQuota>.value(quota);
}
