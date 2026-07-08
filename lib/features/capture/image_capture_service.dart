import 'package:image_picker/image_picker.dart';

abstract class PickerFacade {
  Future<List<String>> pickFromCamera();
  Future<List<String>> pickFromGallery();
}

class ImageCaptureService {
  final PickerFacade picker;
  ImageCaptureService({required this.picker});

  Future<List<String>> captureFromCamera() => picker.pickFromCamera();
  Future<List<String>> pickFromGallery() => picker.pickFromGallery();
}

class ImagePickerFacade implements PickerFacade {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<List<String>> pickFromCamera() async {
    final x = await _picker.pickImage(source: ImageSource.camera);
    if (x == null) return [];
    return [x.path];
  }

  @override
  Future<List<String>> pickFromGallery() async {
    final xs = await _picker.pickMultiImage();
    return xs.map((x) => x.path).toList();
  }
}