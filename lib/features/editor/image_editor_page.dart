import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'tools/color_tool.dart';
import 'tools/crop_tool.dart';
import 'tools/rotate_tool.dart';

const _uuid = Uuid();

class ImageEditorPage extends StatefulWidget {
  final String sourcePath;
  final String manualId;
  final void Function(String editedPath) onSaved;

  const ImageEditorPage({
    super.key,
    required this.sourcePath,
    required this.manualId,
    required this.onSaved,
  });

  @override
  State<ImageEditorPage> createState() => _ImageEditorPageState();
}

class _ImageEditorPageState extends State<ImageEditorPage> {
  img.Image? _decoded;
  double _brightness = 1.0;
  double _contrast = 1.0;
  double _saturation = 1.0;
  int _rotation = 0;
  Uint8List? _previewBytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bytes = await File(widget.sourcePath).readAsBytes();
    setState(() {
      _decoded = img.decodeImage(bytes);
      _previewBytes = bytes;
    });
  }

  img.Image _render() {
    if (_decoded == null) throw Exception('not loaded');
    var im = _decoded!;
    final times = (_rotation / 90).round() % 4;
    for (var i = 0; i < times; i++) {
      im = rotate90(im);
    }
    im = adjustColor(im, brightness: _brightness, contrast: _contrast, saturation: _saturation);
    return im;
  }

  void _onParamChange() {
    setState(() {
      _previewBytes = Uint8List.fromList(img.encodeJpg(_render(), quality: 85));
    });
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
    if (_decoded == null || _previewBytes == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑图片'),
        actions: [TextButton(onPressed: _save, child: const Text('完成'))],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.memory(_previewBytes!, fit: BoxFit.contain),
            ),
          ),
          _SliderRow(
            label: '亮度',
            value: _brightness,
            min: 0.5,
            max: 1.5,
            onChanged: (v) {
              setState(() => _brightness = v);
              _onParamChange();
            },
          ),
          _SliderRow(
            label: '对比度',
            value: _contrast,
            min: 0.5,
            max: 1.5,
            onChanged: (v) {
              setState(() => _contrast = v);
              _onParamChange();
            },
          ),
          _SliderRow(
            label: '饱和度',
            value: _saturation,
            min: 0.0,
            max: 2.0,
            onChanged: (v) {
              setState(() => _saturation = v);
              _onParamChange();
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => _rotation = (_rotation + 90) % 360);
                  _onParamChange();
                },
                icon: const Icon(Icons.rotate_right),
                label: const Text('旋转90°'),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _decoded = cropRect(
                      _decoded!,
                      x: 0,
                      y: 0,
                      w: _decoded!.width,
                      h: _decoded!.height,
                    );
                  });
                  _onParamChange();
                },
                icon: const Icon(Icons.crop),
                label: const Text('裁剪 (整图)'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 64, child: Text(label)),
          Expanded(
            child: Slider(value: value, min: min, max: max, onChanged: onChanged),
          ),
          SizedBox(width: 48, child: Text(value.toStringAsFixed(2))),
        ],
      ),
    );
  }
}
