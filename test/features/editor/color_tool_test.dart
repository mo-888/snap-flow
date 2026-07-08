import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:snapflow/features/editor/tools/color_tool.dart';

void main() {
  test('adjustColor brightens mid-gray pixels', () {
    final src = img.Image(width: 4, height: 4);
    img.fill(src, color: img.ColorRgb8(128, 128, 128));
    final out = adjustColor(src, brightness: 1.2, contrast: 1.0, saturation: 1.0);
    final p = out.getPixel(0, 0);
    expect(p.r, greaterThan(128));
  });
}