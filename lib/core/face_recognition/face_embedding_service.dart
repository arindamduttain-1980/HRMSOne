import 'dart:io';
import 'dart:ui';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'face_detector_service.dart';

class FaceEmbeddingService {
  Interpreter? _interpreter;

  Future<void> loadModel({
    String modelPath = 'assets/model/mobileFaceNet.tflite',
  }) async {
    _interpreter ??= await Interpreter.fromAsset(modelPath);
  }

  Future<List<double>> generateEmbeddingFromImageFile(File imageFile) async {
    final detector = FaceDetectorService();
    try {
      final faces = await detector.detectFacesFromPath(imageFile.path);
      if (faces.isEmpty) {
        throw Exception("No face detected in the image for embedding generation");
      }
      return await generateEmbedding(imageFile.path, faces.first.boundingBox);
    } finally {
      detector.dispose();
    }
  }

  Future<List<double>> generateEmbedding(String imagePath, Rect faceBox) async {
    if (_interpreter == null) {
      await loadModel();
    }

    final imageFile = File(imagePath);
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception("Image decode failed for path: $imagePath");
    }

    // Add ~10% margin around the detected box to prevent overly tight cropping
    const margin = 0.1;
    final boxW = faceBox.width;
    final boxH = faceBox.height;

    final left = (faceBox.left - boxW * margin).clamp(0, image.width.toDouble()).toInt();
    final top = (faceBox.top - boxH * margin).clamp(0, image.height.toDouble()).toInt();
    final right = (faceBox.right + boxW * margin).clamp(0, image.width.toDouble()).toInt();
    final bottom = (faceBox.bottom + boxH * margin).clamp(0, image.height.toDouble()).toInt();

    final cropWidth = (right - left).clamp(1, image.width - left);
    final cropHeight = (bottom - top).clamp(1, image.height - top);

    final cropped = img.copyCrop(
      image,
      x: left,
      y: top,
      width: cropWidth,
      height: cropHeight,
    );

    final inputShape = _interpreter!.getInputTensor(0).shape;
    final outputShape = _interpreter!.getOutputTensor(0).shape;

    final batchSize = (inputShape.isNotEmpty && inputShape[0] > 0) ? inputShape[0] : 1;
    final modelHeight = (inputShape.length > 1 && inputShape[1] > 0) ? inputShape[1] : 112;
    final modelWidth = (inputShape.length > 2 && inputShape[2] > 0) ? inputShape[2] : 112;
    final outputDim = (outputShape.length > 1 && outputShape[1] > 0) ? outputShape[1] : 192;

    final resized = img.copyResize(
      cropped,
      width: modelWidth,
      height: modelHeight,
    );

    final frame = _imageToNormalizedList(resized, modelWidth, modelHeight);
    final input = List.generate(batchSize, (_) => frame);
    final output = List.generate(batchSize, (_) => List.filled(outputDim, 0.0));

    _interpreter!.run(input, output);

    return List<double>.from(output[0]);
  }

  List _imageToNormalizedList(img.Image image, int width, int height) {
    return List.generate(
      height,
      (y) => List.generate(width, (x) {
        final pixel = image.getPixel(x, y);
        return [
          (pixel.r - 127.5) / 127.5,
          (pixel.g - 127.5) / 127.5,
          (pixel.b - 127.5) / 127.5,
        ];
      }),
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}

