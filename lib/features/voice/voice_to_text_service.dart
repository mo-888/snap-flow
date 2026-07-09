import 'dart:typed_data';

abstract class AsrAdapter {
  /// 返回识别到的文字（空串表示未识别）。
  /// 不抛异常；调用方根据返回判断。
  Future<String> transcribe(Uint8List audio);
}

/// 占位 STT：始终返回空串。后续可替换为 sherpa-onnx/whisper。
class FakeAsr implements AsrAdapter {
  @override
  Future<String> transcribe(Uint8List audio) async => '';
}

/// 同 FakeAsr，命名更明确语义。
class OfflineAsr implements AsrAdapter {
  @override
  Future<String> transcribe(Uint8List audio) async => '';
}

class VoiceToTextService {
  final AsrAdapter asr;
  VoiceToTextService({required this.asr});

  Future<String> transcribe(Uint8List audio) async {
    if (audio.isEmpty) return '';
    return asr.transcribe(audio);
  }
}