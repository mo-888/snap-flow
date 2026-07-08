import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'voice_to_text_service.dart';

class VoiceButton extends StatefulWidget {
  final VoiceToTextService service;
  final void Function(String text) onResult;

  const VoiceButton({super.key, required this.service, required this.onResult});

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton> {
  final _recorder = AudioRecorder();
  bool _recording = false;
  bool _busy = false;

  Future<void> _start() async {
    if (await _recorder.hasPermission()) {
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 64000),
        path: 'rec_${DateTime.now().millisecondsSinceEpoch}.m4a',
      );
      setState(() => _recording = true);
    }
  }

  Future<void> _stop() async {
    if (!_recording) return;
    setState(() {
      _recording = false;
      _busy = true;
    });
    final path = await _recorder.stop();
    if (path == null) {
      setState(() => _busy = false);
      return;
    }
    try {
      final bytes = await File(path).readAsBytes();
      final text = await widget.service.transcribe(Uint8List.fromList(bytes));
      widget.onResult(text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('识别失败：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _start(),
      onLongPressEnd: (_) => _stop(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _recording ? Colors.red.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_recording ? Icons.mic : Icons.mic_none,
                color: _recording ? Colors.red : null),
            const SizedBox(width: 4),
            Text(_busy ? '识别中…' : (_recording ? '松开发送' : '按住说话')),
          ],
        ),
      ),
    );
  }
}