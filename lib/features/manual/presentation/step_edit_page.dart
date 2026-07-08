import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/providers.dart';
import '../../capture/image_capture_service.dart';
import '../../voice/voice_button.dart';
import '../../voice/voice_to_text_service.dart';
import '../domain/entities.dart' as domain;
import 'manual_detail_page.dart';
import 'widgets/thumb_grid.dart';

const _uuid = Uuid();

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
  domain.Step? _step;
  domain.Manual? _manual;
  bool _loading = true;

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
      orElse: () => domain.Step(
        id: widget.stepId,
        order: 0,
        title: null,
        note: '',
        completed: false,
        images: const [],
        optionalFields: const {},
      ),
    );
    setState(() {
      _manual = m;
      _step = s;
      _titleCtl.text = s.title ?? '';
      _noteCtl.text = s.note;
      _loading = false;
    });
  }

  Future<void> _addImages({required bool fromCamera}) async {
    final svc = ImageCaptureService(picker: ImagePickerFacade());
    final paths = fromCamera ? await svc.captureFromCamera() : await svc.pickFromGallery();
    if (paths.isEmpty || _manual == null || _step == null) return;

    final newImages = <domain.StepImage>[];
    for (final p in paths) {
      final src = File(p);
      final imageId = _uuid.v4();
      final originalPath = await savePickedImage(source: src, manualId: _manual!.id);
      final thumbPath = await generateThumbnailFor(
        source: src,
        manualId: _manual!.id,
        imageId: imageId,
      );
      newImages.add(domain.StepImage(
        id: imageId,
        order: (_step!.images.length + newImages.length) * 100,
        originalPath: originalPath,
        editedPath: null,
        thumbnailPath: thumbPath,
      ));
    }

    final updatedStep = _step!.copyWith(images: [..._step!.images, ...newImages]);
    final newSteps =
        _manual!.steps.map((s) => s.id == updatedStep.id ? updatedStep : s).toList();
    final repo = await ref.read(manualRepositoryProvider.future);
    await repo.saveManual(_manual!.copyWith(steps: newSteps, updatedAt: DateTime.now()));
    setState(() => _step = updatedStep);
    ref.invalidate(manualDetailProvider(_manual!.id));
  }

  Future<void> _deleteImage(int idx) async {
    if (_step == null || _manual == null) return;
    final newImages = [..._step!.images]..removeAt(idx);
    final updatedStep = _step!.copyWith(images: newImages);
    final newSteps =
        _manual!.steps.map((s) => s.id == updatedStep.id ? updatedStep : s).toList();
    final repo = await ref.read(manualRepositoryProvider.future);
    await repo.saveManual(_manual!.copyWith(steps: newSteps, updatedAt: DateTime.now()));
    setState(() => _step = updatedStep);
    ref.invalidate(manualDetailProvider(_manual!.id));
  }

  Future<void> _save() async {
    if (_step == null || _manual == null) return;
    final updatedStep = _step!.copyWith(
      title: _titleCtl.text.isEmpty ? null : _titleCtl.text,
      note: _noteCtl.text,
    );
    final newSteps =
        _manual!.steps.map((s) => s.id == updatedStep.id ? updatedStep : s).toList();
    final repo = await ref.read(manualRepositoryProvider.future);
    await repo.saveManual(_manual!.copyWith(steps: newSteps, updatedAt: DateTime.now()));
    ref.invalidate(manualDetailProvider(_manual!.id));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑步骤'),
        actions: [TextButton(onPressed: _save, child: const Text('保存'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleCtl,
            decoration: const InputDecoration(labelText: '标题（可空）'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton.icon(
                onPressed: () => _addImages(fromCamera: true),
                icon: const Icon(Icons.photo_camera),
                label: const Text('拍照'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _addImages(fromCamera: false),
                icon: const Icon(Icons.photo_library),
                label: const Text('相册'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('图片（${_step?.images.length ?? 0}）'),
          const SizedBox(height: 8),
          ThumbGrid(
            images: _step?.images ?? const [],
            onTap: (i) {},
            onDelete: _deleteImage,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _noteCtl,
                  decoration: const InputDecoration(labelText: '说明'),
                  maxLines: 5,
                ),
              ),
              const SizedBox(width: 8),
              VoiceButton(
                service: VoiceToTextService(asr: FakeAsr()),
                onResult: (text) => setState(() {
                  _noteCtl.text = _noteCtl.text.isEmpty ? text : '${_noteCtl.text} $text';
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}