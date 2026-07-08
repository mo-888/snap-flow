import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapflow/features/voice/voice_to_text_service.dart';

void main() {
  test('FakeAsr transcribes known input', () async {
    final svc = VoiceToTextService(asr: FakeAsr());
    final result = await svc.transcribe(Uint8List.fromList([1, 2, 3]));
    expect(result, contains('hello'));
  });

  test('Rejects empty audio', () async {
    final svc = VoiceToTextService(asr: FakeAsr());
    expect(
      () => svc.transcribe(Uint8List(0)),
      throwsA(isA<ArgumentError>()),
    );
  });
}