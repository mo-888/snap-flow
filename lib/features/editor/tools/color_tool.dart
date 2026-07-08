import 'package:image/image.dart' as img;

img.Image adjustColor(
  img.Image src, {
  required double brightness,
  required double contrast,
  required double saturation,
}) {
  img.Image out = img.Image.from(src);
  out = img.adjustColor(out, brightness: brightness, contrast: contrast, saturation: saturation);
  return out;
}