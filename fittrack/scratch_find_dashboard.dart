import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File(r'C:\Users\dinet\.gemini\antigravity-ide\brain\ddec9ae6-2f27-4e30-858f-fe98051ba081\device_screen31.png');
  final bytes = file.readAsBytesSync();
  final image = img.decodeImage(bytes)!;

  print('Searching for Dashboard icon (outline) in X: 50..250, Y: 2130..2220');
  // Find pixels that are significantly darker than the white dock background
  int minX = 9999, maxX = -1, minY = 9999, maxY = -1;
  for (int y = 2140; y < 2210; y++) {
    for (int x = 50; x < 250; x++) {
      final p = image.getPixel(x, y);
      // background of dock is whitish (r>200, g>200, b>200)
      // icon lines have luminance < 180
      final lum = 0.299 * p.r + 0.587 * p.g + 0.114 * p.b;
      if (lum < 160) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }

  print('Dashboard icon found at X: $minX..$maxX, Y: $minY..$maxY');
}
