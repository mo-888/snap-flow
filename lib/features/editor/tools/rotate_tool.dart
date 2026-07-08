import 'package:image/image.dart' as img;

img.Image rotate90(img.Image src) => img.copyRotate(src, angle: 90);
img.Image rotateFree(img.Image src, double angle) => img.copyRotate(src, angle: angle);