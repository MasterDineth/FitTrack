import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File(r'C:\Users\dinet\.gemini\antigravity-ide\brain\ddec9ae6-2f27-4e30-858f-fe98051ba081\device_screen31.png');
  final bytes = file.readAsBytesSync();
  final image = img.decodeImage(bytes)!;

  print('Image dimensions: ${image.width} x ${image.height}');

  // Look at rows near the bottom from y = 2000 to 2350
  // Search for the dock border or icon colors
  // Primary color: #5F3BDC -> R=95, G=59, B=220
  // Let's find pixels close to #5F3BDC in y: [2050, 2300]
  int minX = 9999, maxX = -1, minY = 9999, maxY = -1;
  int icon2MinX = 9999, icon2MaxX = -1, icon2MinY = 9999, icon2MaxY = -1;

  for (int y = 2050; y < 2300; y++) {
    for (int x = 0; x < image.width; x++) {
      final p = image.getPixel(x, y);
      final r = p.r;
      final g = p.g;
      final b = p.b;

      // Check if primary color (Dashboard pill text or icon)
      if (r > 70 && r < 120 && g > 40 && g < 80 && b > 190) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }

      // Check for dumbbell icon (grey muted icon: R~100-160, G~100-160, B~140-190, but darker than background)
      // Muted color in FtGlassTheme: #6B6785 -> R=107, G=103, B=133
      if (x > 450 && x < 650 && r > 90 && r < 130 && g > 85 && g < 125 && b > 115 && b < 155) {
        if (x < icon2MinX) icon2MinX = x;
        if (x > icon2MaxX) icon2MaxX = x;
        if (y < icon2MinY) icon2MinY = y;
        if (y > icon2MaxY) icon2MaxY = y;
      }
    }
  }

  print('Dashboard pill active area: X: $minX..$maxX, Y: $minY..$maxY');
  print('Dumbbell icon area: X: $icon2MinX..$icon2MaxX, Y: $icon2MinY..$icon2MaxY');
}
