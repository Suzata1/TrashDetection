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

  final uvRowStride = image.planes[1].bytesPerRow;
  final uvPixelStride = image.planes[1].bytesPerPixel!;

  final imgImage = img.Image(width: width, height: height);

  for (var w = 0; w < width; w++) {
    for (var h = 0; h < height; h++) {
      final uvIndex =
          uvPixelStride * (w / 2).floor() + uvRowStride * (h / 2).floor();
      final index = h * image.planes[0].bytesPerRow + w;

      final y = image.planes[0].bytes[index];
      final u = image.planes[1].bytes[uvIndex];
      final v = image.planes[2].bytes[uvIndex];

      imgImage.setPixelRgb(w, h, y, u, v);
    }
  }

  // The camera image often comes in rotated 90 degrees clockwise on mobile.
  // We can return the raw image and let the caller handle rotation, or rotate it here.
  return imgImage;
}
