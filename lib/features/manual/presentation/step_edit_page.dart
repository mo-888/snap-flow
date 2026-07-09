import 'dart:io';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../features/capture/image_capture_service.dart';
import '../../../features/voice/voice_button.dart';
import '../../../features/voice/voice_to_text_service.dart';
import '../../../shared/providers.dart';
import '../domain/entities.dart';
import 'manual_detail_page.dart';
import 'widgets/thumb_grid.dart';

const _uuid = Uuid();
const _defaultNewStepFields = {'确认人': '', '日期': ''};

class StepEditPage extends ConsumerStatefulWidget {
  final String manualId;
  final String stepId;
  const StepEditPage({super.key, required this.manualId, required this.stepId});

  @override
  ConsumerState<StepEditPage> createState() => _StepEditPageState();
}

class _StepEditPageState extends ConsumerState<StepEditPage> {
  late TextEditingController _titleCtl;
  late TextEditingController _noteCtl;
  Step? _step;
  Manual? _manual;
  bool _loading = true;
  final List<_FieldRow> _fieldRows = [];

  @override
  void initState() {
    super.initState();
    _titleCtl = TextEditingController();
    _noteCtl = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final repo = await ref.read(manualRepositoryProvider.future);
    final m = await repo.getManual(widget.manualId);
    if (m == null) {
      setState(() => _loading = false);
      return;
    }
    final s = m.steps.firstWhere(
      (e) => e.id == widget.stepId,
      orElse: () => Step(
        id: widget.stepId, order: 0, title: null, note: '', completed: false,
        images: const [], optionalFields: const {},
        createdAt: DateTime.now(),
      ),
    );
    _fieldRows.clear();
    final initialFields = s.optionalFields.isEmpty ? _defaultNewStepFields : s.optionalFields;
    initialFields.forEach((k, v) {
      _fieldRows.add(_FieldRow(keyCtl: TextEditingController(text: k), valCtl: TextEditingController(text: v)));
    });
    setState(() {
      _manual = m;
      _step = s;
      _titleCtl.text = s.title ?? '';
      _noteCtl.text = s.note;
      _loading = false;
    });
  }

  Future<void> _addImages(bool fromCamera) async {
    final svc = ImageCaptureService(picker: ImagePickerFacade());
    final paths = fromCamera ? await svc.captureFromCamera() : await svc.pickFromGallery();
    if (paths.isEmpty || _manual == null || _step == null) return;
    final newImages = <StepImage>[];
    for (final p in paths) {
      final src = File(p);
      final imageId = _uuid.v4();
      final originalPath = await savePickedImage(source: src, manualId: _manual!.id);
      final thumbPath = await generateThumbnailFor(source: src, manualId: _manual!.id, imageId: imageId);
      newImages.add(StepImage(
        id: imageId,
        order: (_step!.images.length + newImages.length) * 100,
        originalPath: originalPath, editedPath: null, thumbnailPath: thumbPath,
      ));
    }
    final updated = _step!.copyWith(images: [..._step!.images, ...newImages]);
    final newSteps = _manual!.steps.map((s) => s.id == updated.id ? updated : s).toList();
    final repo = await ref.read(manualRepositoryProvider.future);
    await repo.saveManual(_manual!.copyWith(steps: newSteps, updatedAt: DateTime.now()));
    setState(() => _step = updated);
    ref.invalidate(manualDetailProvider(_manual!.id));
  }

  Future<void> _deleteImage(int idx) async {
    if (_step == null || _manual == null) return;
    final newImages = [..._step!.images]..removeAt(idx);
    final updated = _step!.copyWith(images: newImages);
    final newSteps = _manual!.steps.map((s) => s.id == updated.id ? updated : s).toList();
    final repo = await ref.read(manualRepositoryProvider.future);
    await repo.saveManual(_manual!.copyWith(steps: newSteps, updatedAt: DateTime.now()));
    setState(() => _step = updated);
    ref.invalidate(manualDetailProvider(_manual!.id));
  }

  Future<void> _save() async {
    if (_step == null || _manual == null) return;
    final fields = <String, String>{};
    for (final r in _fieldRows) {
      final k = r.keyCtl.text.trim();
      if (k.isNotEmpty) fields[k] = r.valCtl.text;
    }
    final updated = _step!.copyWith(
      title: _titleCtl.text.isEmpty ? null : _titleCtl.text,
      note: _noteCtl.text,
      optionalFields: fields,
    );
    final newSteps = _manual!.steps.map((s) => s.id == updated.id ? updated : s).toList();
    final repo = await ref.read(manualRepositoryProvider.future);
    await repo.saveManual(_manual!.copyWith(steps: newSteps, updatedAt: DateTime.now()));
    ref.invalidate(manualDetailProvider(_manual!.id));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        title: const Text('编辑步骤'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _FieldWithMic(
            label: '标题',
            placeholder: '例如：关闭总闸',
            controller: _titleCtl,
            onMicResult: (t) => setState(() => _titleCtl.text = t),
          ),
          const SizedBox(height: 16),
          _FieldWithMic(
            label: '说明',
            placeholder: '详细描述这一步要做什么...\n\n可用右侧 🎤 语音输入',
            controller: _noteCtl,
            maxLines: 5,
            onMicResult: (t) => setState(() => _noteCtl.text = _noteCtl.text.isEmpty ? t : '${_noteCtl.text} $t'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.tonalIcon(
                onPressed: () => _addImages(true),
                icon: const Icon(Icons.photo_camera),
                label: const Text('拍照'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _addImages(false),
                icon: const Icon(Icons.photo_library),
                label: const Text('相册'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('图片（${_step?.images.length ?? 0}/9）'),
          const SizedBox(height: 8),
          ThumbGrid(
            images: _step?.images ?? const [],
            onTap: (i) {},
            onDelete: _deleteImage,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('附加字段', style: Theme.of(context).textTheme.titleSmall),
              TextButton.icon(
                onPressed: () => setState(() => _fieldRows.add(_FieldRow(keyCtl: TextEditingController(), valCtl: TextEditingController()))),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('加字段'),
              ),
            ],
          ),
          for (var i = 0; i < _fieldRows.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(flex: 3, child: TextField(controller: _fieldRows[i].keyCtl, decoration: const InputDecoration(hintText: '字段名', isDense: true))),
                  const SizedBox(width: 6),
                  Expanded(flex: 5, child: TextField(controller: _fieldRows[i].valCtl, decoration: const InputDecoration(hintText: '值', isDense: true))),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    onPressed: () => setState(() => _fieldRows.removeAt(i)),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消'))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton(onPressed: _save, child: const Text('保存步骤'))),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldRow {
  final TextEditingController keyCtl;
  final TextEditingController valCtl;
  _FieldRow({required this.keyCtl, required this.valCtl});
}

class _FieldWithMic extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final int maxLines;
  final void Function(String) onMicResult;
  const _FieldWithMic({
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.onMicResult,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Stack(
          children: [
            TextField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(hintText: placeholder),
            ),
            Positioned(
              right: 8, top: maxLines == 1 ? 6 : 8,
              child: VoiceButton(
                service: VoiceToTextService(asr: FakeAsr()),
                onResult: onMicResult,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
