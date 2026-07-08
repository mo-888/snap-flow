import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'tools/color_tool.dart';
// ignore: unused_import
import 'tools/crop_tool.dart';
import 'tools/rotate_tool.dart';

const _uuid = Uuid();
enum _Tool { crop, rotate, adjust, annotate, mosaic }

class ImageEditorPage extends StatefulWidget {
  final String sourcePath;
  final String manualId;
  final void Function(String editedPath) onSaved;
  const ImageEditorPage({super.key, required this.sourcePath, required this.manualId, required this.onSaved});

  @override
  State<ImageEditorPage> createState() => _ImageEditorPageState();
}

class _ImageEditorPageState extends State<ImageEditorPage> {
  img.Image? _decoded;
  _Tool _tool = _Tool.crop;
  double _brightness = 1.0, _contrast = 1.0, _saturation = 1.0;
  int _rotation = 0;
  Uint8List? _preview;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bytes = await File(widget.sourcePath).readAsBytes();
    setState(() {
      _decoded = img.decodeImage(bytes);
      _preview = bytes;
    });
  }

  img.Image _render() {
    if (_decoded == null) throw Exception('not loaded');
    var im = _decoded!;
    for (var i = 0; i < (_rotation / 90).round() % 4; i++) {
      im = rotate90(im);
    }
    im = adjustColor(im, brightness: _brightness, contrast: _contrast, saturation: _saturation);
    return im;
  }

  void _onParamChange() {
    setState(() => _preview = Uint8List.fromList(img.encodeJpg(_render(), quality: 85)));
  }

  Future<void> _save() async {
    final out = _render();
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'images', 'edited', widget.manualId));
    await dir.create(recursive: true);
    final path = p.join(dir.path, '${_uuid.v4()}.jpg');
    await File(path).writeAsBytes(img.encodeJpg(out, quality: 85));
    widget.onSaved(path);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_decoded == null || _preview == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(child: Image.memory(_preview!, fit: BoxFit.contain)),
            ),
            if (_tool == _Tool.adjust)
              _AdjustPanel(
                brightness: _brightness, contrast: _contrast, saturation: _saturation,
                onChanged: (b, c, s) { setState(() { _brightness = b; _contrast = c; _saturation = s; }); _onParamChange(); },
              ),
            Container(
              color: const Color(0xFF1F2937),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  _ToolBtn(icon: Icons.crop, label: '裁剪', active: _tool == _Tool.crop, onTap: () => setState(() => _tool = _Tool.crop)),
                  _ToolBtn(icon: Icons.rotate_right, label: '旋转', active: _tool == _Tool.rotate, onTap: () { setState(() { _tool = _Tool.rotate; _rotation = (_rotation + 90) % 360; }); _onParamChange(); }),
                  _ToolBtn(icon: Icons.tune, label: '调色', active: _tool == _Tool.adjust, onTap: () => setState(() => _tool = _Tool.adjust)),
                  _ToolBtn(icon: Icons.edit, label: '标注', active: _tool == _Tool.annotate, onTap: () => setState(() => _tool = _Tool.annotate)),
                  _ToolBtn(icon: Icons.blur_on, label: '马赛克', active: _tool == _Tool.mosaic, onTap: () => setState(() => _tool = _Tool.mosaic)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: 4),
                  FilledButton(onPressed: _save, child: const Text('完成')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon; final String label; final bool active; final VoidCallback onTap;
  const _ToolBtn({required this.icon, required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: active ? Colors.white12 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, color: active ? Colors.white : Colors.white70, size: 20), Text(label, style: TextStyle(color: active ? Colors.white : Colors.white70, fontSize: 10))],
        ),
      ),
    );
  }
}

class _AdjustPanel extends StatelessWidget {
  final double brightness, contrast, saturation;
  final void Function(double, double, double) onChanged;
  const _AdjustPanel({required this.brightness, required this.contrast, required this.saturation, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1F2937),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _Slider(label: '亮度', min: 0.5, max: 1.5, value: brightness, onChanged: (v) => onChanged(v, contrast, saturation)),
          _Slider(label: '对比', min: 0.5, max: 1.5, value: contrast, onChanged: (v) => onChanged(brightness, v, saturation)),
          _Slider(label: '饱和', min: 0.0, max: 2.0, value: saturation, onChanged: (v) => onChanged(brightness, contrast, v)),
        ],
      ),
    );
  }
}

class _Slider extends StatelessWidget {
  final String label; final double min, max, value; final ValueChanged<double> onChanged;
  const _Slider({required this.label, required this.min, required this.max, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(width: 48, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12))),
      Expanded(child: Slider(value: value, min: min, max: max, onChanged: onChanged)),
      SizedBox(width: 36, child: Text(value.toStringAsFixed(2), style: const TextStyle(color: Colors.white70, fontSize: 11))),
    ]);
  }
}
