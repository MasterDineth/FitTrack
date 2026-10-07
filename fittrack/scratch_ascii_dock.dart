import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File(r'C:\Users\dinet\.gemini\antigravity-ide\brain\ddec9ae6-2f27-4e30-858f-fe98051ba081\device_screen32.png');
  final bytes = file.readAsBytesSync();
  final image = img.decodeImage(bytes)!;

  // Print a small ASCII grid of the region x: 80..220 (step 4), y: 2140..2200 (step 2)
  for (int y = 2140; y < 2200; y += 2) {
    final sb = StringBuffer('$y: ');
    for (int x = 80; x < 240; x += 3) {
      final p = image.getPixel(x, y);
      final lum = 0.299 * p.r + 0.587 * p.g + 0.114 * p.b;
      sb.write(lum < 160 ? '#' : '.');
    }
    print(sb.toString());
  }
}
