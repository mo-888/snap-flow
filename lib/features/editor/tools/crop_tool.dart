import 'package:image/image.dart' as img;

img.Image cropRect(
  img.Image src, {
  required int x,
  required int y,
  required int w,
  required int h,
}) {
  return img.copyCrop(src, x: x, y: y, width: w, height: h);
}