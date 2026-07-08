import 'dart:typed_data';

abstract class AsrAdapter {
  Future<String> transcribe(Uint8List audio);
}

class FakeAsr implements AsrAdapter {
  @override
  Future<String> transcribe(Uint8List audio) async => 'hello world';
}

class VoiceToTextService {
  final AsrAdapter asr;
  VoiceToTextService({required this.asr});

  Future<String> transcribe(Uint8List audio) async {
    if (audio.isEmpty) throw ArgumentError('audio is empty');
    return asr.transcribe(audio);
  }
}