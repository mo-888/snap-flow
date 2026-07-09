import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'voice_to_text_service.dart';

/// 按住说话按钮 + 文字输入回退入口。
///
/// 修复点：
/// 1. start/stop 失败不再导致崩溃（用 try/catch + SnackBar）
/// 2. 识别返回空串时弹文字输入 dialog，不报错
/// 3. 右侧加"⌨ 文字"图标，点击直接弹 dialog
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
    if (_recording || _busy) return;
    try {
      final hasPerm = await _recorder.hasPermission();
      if (!hasPerm) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('未授予麦克风权限')),
          );
        }
        return;
      }
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 64000),
        path: 'rec_${DateTime.now().millisecondsSinceEpoch}.m4a',
      );
      if (mounted) setState(() => _recording = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('录音启动失败：$e')),
        );
      }
    }
  }

  Future<void> _stop() async {
    if (!_recording) return;
    setState(() {
      _recording = false;
      _busy = true;
    });
    String? path;
    try {
      path = await _recorder.stop();
    } catch (_) {
      path = null;
    }
    String text = '';
    if (path != null) {
      try {
        final bytes = await File(path).readAsBytes();
        text = await widget.service.transcribe(bytes);
      } catch (_) {
        text = '';
      }
    }
    if (!mounted) return;
    setState(() => _busy = false);

    if (text.isNotEmpty) {
      widget.onResult(text);
      return;
    }
    // 未识别到内容，弹文字输入 fallback
    final typed = await _askTextFallback();
    if (typed != null && typed.isNotEmpty) widget.onResult(typed);
  }

  Future<String?> _askTextFallback() async {
    if (!mounted) return null;
    final ctl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('未识别到内容'),
        content: TextField(
          controller: ctl,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: '请手动输入文字',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.of(context).pop(ctl.text.trim()), child: const Text('确定')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
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
        ),
        const SizedBox(width: 6),
        IconButton(
          tooltip: '文字输入',
          icon: const Icon(Icons.keyboard_alt_outlined, size: 20),
          onPressed: () async {
            final t = await _askTextFallback();
            if (t != null && t.isNotEmpty) widget.onResult(t);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }
}