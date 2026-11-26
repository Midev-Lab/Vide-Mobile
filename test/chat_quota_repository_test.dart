import 'package:flutter_test/flutter_test.dart';
import 'package:vide/features/quota/services/chat_quota_repository.dart';

void main() {
  test('unknown repository never invents a remaining quota', () async {
    const repository = UnknownChatQuotaRepository();

    expect((await repository.fetch()).remaining, isNull);
    expect((await repository.watch().first).remaining, isNull);
  });

  test('debug override accepts only approved screenshot values', () async {
    const overrides = <String, int?>{'unknown': null, '0': 0, '1': 1, '5': 5};

    for (final entry in overrides.entries) {
      final repository = DebugChatQuotaRepository.fromOverride(entry.key);
      expect((await repository.fetch()).remaining, entry.value);
    }

    expect(
      () => DebugChatQuotaRepository.fromOverride('3'),
      throwsFormatException,
    );
  });
}
