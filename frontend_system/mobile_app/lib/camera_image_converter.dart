import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

/// Converts a CameraImage to an img.Image.
/// This runs the heavy conversion on the main thread, 
/// but since we'll only do it periodically it should be fine.
/// For true production performance, this should be moved to an Isolate.
img.Image? convertCameraImage(CameraImage image) {
  try {
    if (image.format.group == ImageFormatGroup.yuv420) {
      return _convertYUV420(image);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      return _convertBGRA8888(image);
    }
  } catch (e) {
    print("Error converting camera image: $e");
  }
  return null;
}

img.Image _convertBGRA8888(CameraImage image) {
  return img.Image.fromBytes(
    width: image.width,
    height: image.height,
    bytes: image.planes[0].bytes.buffer,
    order: img.ChannelOrder.bgra,
  );
}

img.Image _convertYUV420(CameraImage image) {
  final width = image.width;
  final height = image.height;

  final yPlane = image.planes[0];
  final uPlane = image.planes[1];
  final vPlane = image.planes[2];

  final int uvRowStride = uPlane.bytesPerRow;
  final int uvPixelStride = uPlane.bytesPerPixel!;

  final imgImage = img.Image(width: width, height: height);

  for (int h = 0; h < height; h++) {
    for (int w = 0; w < width; w++) {
      final int yIndex = h * yPlane.bytesPerRow + w;
      final int uvIndex =
          uvPixelStride * (w ~/ 2) + uvRowStride * (h ~/ 2);

      final int y = yPlane.bytes[yIndex];
      final int u = uPlane.bytes[uvIndex];
      final int v = vPlane.bytes[uvIndex];

      // Proper YUV420 to RGB conversion
      int r = (y + 1.370705 * (v - 128)).round().clamp(0, 255);
      int g = (y - 0.337633 * (u - 128) - 0.698001 * (v - 128)).round().clamp(0, 255);
      int b = (y + 1.732446 * (u - 128)).round().clamp(0, 255);

      imgImage.setPixelRgb(w, h, r, g, b);
    }
  }

  return imgImage;
}
