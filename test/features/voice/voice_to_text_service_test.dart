import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapflow/features/voice/voice_to_text_service.dart';

void main() {
  test('FakeAsr returns empty string (offline placeholder)', () async {
    final svc = VoiceToTextService(asr: FakeAsr());
    final result = await svc.transcribe(Uint8List.fromList([1, 2, 3]));
    expect(result, isEmpty);
  });

  test('Empty audio returns empty string (no throw)', () async {
    final svc = VoiceToTextService(asr: FakeAsr());
    final result = await svc.transcribe(Uint8List(0));
    expect(result, isEmpty);
  });

  test('OfflineAsr returns empty string', () async {
    final svc = VoiceToTextService(asr: OfflineAsr());
    final result = await svc.transcribe(Uint8List.fromList([1, 2, 3]));
    expect(result, isEmpty);
  });
}