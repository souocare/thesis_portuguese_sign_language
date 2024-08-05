import 'package:camera/camera.dart';
import 'package:image/image.dart' as imageLib;

class ImageUtils {
  static imageLib.Image convertCameraImageToImage(CameraImage cameraImage) {
    // Check image format and handle accordingly
    if (cameraImage.planes.length == 3) {
      // Handle YUV420 format
      return convertYUV420ToImage(cameraImage);
    } else if (cameraImage.planes.length == 1) {
      // Handle raw RGB format
      return convertBGRA8888ToImage2(cameraImage);
    } else {
      throw Exception('Unsupported image format');
    }
  }

  static imageLib.Image convertBGRA8888ToImage2(CameraImage cameraImage) {
    return imageLib.Image.fromBytes(
      cameraImage.width,
      cameraImage.height,
      cameraImage.planes[0].bytes,
    );
  }

  static imageLib.Image convertBGRA8888ToImage(CameraImage cameraImage) {
    return imageLib.Image.fromBytes(
      cameraImage.planes[0].width!,
      cameraImage.planes[0].height!,
      cameraImage.planes[0].bytes,
    );
  }

  static imageLib.Image convertYUV420ToImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;

    final int ySize = width * height;
    final int uvSize = (width / 2).ceil() * (height / 2).ceil();
    final List<int> yPlane = cameraImage.planes[0].bytes;
    final List<int> uPlane = cameraImage.planes[1].bytes;
    final List<int> vPlane = cameraImage.planes[2].bytes;

    final image = imageLib.Image(width, height);

    for (int h = 0; h < height; h++) {
      for (int w = 0; w < width; w++) {
        final int yIndex = h * width + w;
        final int uvRowIndex = (h ~/ 2) * (width ~/ 2);
        final int uvIndex = uvRowIndex + (w ~/ 2);

        final int y = yPlane[yIndex];
        final int u = uPlane[uvIndex];
        final int v = vPlane[uvIndex];

        image.data[h * width + w] = yuv2rgb(y, u, v);
      }
    }
    return image;
  }

  static imageLib.Image convertRawRGBToImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;

    final List<int> planeBytes = cameraImage.planes[0].bytes;

    final image = imageLib.Image(width, height);

    for (int h = 0; h < height; h++) {
      for (int w = 0; w < width; w++) {
        final int index = (h * width + w) * 3; // Assuming RGB format
        final int r = planeBytes[index];
        final int g = planeBytes[index + 1];
        final int b = planeBytes[index + 2];

        image.data[h * width + w] = 0xff000000 |
            ((b << 16) & 0xff0000) |
            ((g << 8) & 0xff00) |
            (r & 0xff);
      }
    }

    return image;
  }

  static int yuv2rgb(int y, int u, int v) {
    int r = (y + (v - 128) * 1.402).round();
    int g = (y - (u - 128) * 0.344136 - (v - 128) * 0.714136).round();
    int b = (y + (u - 128) * 1.772).round();

    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);

    return 0xff000000 |
        ((b << 16) & 0xff0000) |
        ((g << 8) & 0xff00) |
        (r & 0xff);
  }
}
