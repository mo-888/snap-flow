import 'package:flutter_test/flutter_test.dart';
import 'package:snapflow/features/capture/image_capture_service.dart';

void main() {
  test('Service is constructible with a facade', () {
    final svc = ImageCaptureService(picker: _NoopPicker());
    expect(svc, isNotNull);
  });

  test('captureFromCamera delegates to picker', () async {
    final svc = ImageCaptureService(picker: _StubPicker(cameraPaths: ['/a.jpg']));
    final r = await svc.captureFromCamera();
    expect(r, ['/a.jpg']);
  });

  test('pickFromGallery delegates to picker', () async {
    final svc = ImageCaptureService(picker: _StubPicker(galleryPaths: ['/b.jpg', '/c.jpg']));
    final r = await svc.pickFromGallery();
    expect(r, ['/b.jpg', '/c.jpg']);
  });
}

class _NoopPicker implements PickerFacade {
  @override
  Future<List<String>> pickFromCamera() async => [];
  @override
  Future<List<String>> pickFromGallery() async => [];
}

class _StubPicker implements PickerFacade {
  final List<String> cameraPaths;
  final List<String> galleryPaths;
  _StubPicker({this.cameraPaths = const [], this.galleryPaths = const []});
  @override
  Future<List<String>> pickFromCamera() async => cameraPaths;
  @override
  Future<List<String>> pickFromGallery() async => galleryPaths;
}