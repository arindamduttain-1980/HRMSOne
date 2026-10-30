import 'dart:io';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorService {
  final FaceDetector _faceDetector;

  FaceDetectorService()
      : _faceDetector = FaceDetector(
          options: FaceDetectorOptions(
            performanceMode: FaceDetectorMode.accurate,
            enableContours: true,
            enableLandmarks: true,
            enableClassification: true,
            minFaceSize: 0.15,
          ),
        );

  Future<List<Face>> detectFacesFromPath(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    return await _faceDetector.processImage(inputImage);
  }

  Future<List<Face>> detectFacesFromInputImage(InputImage inputImage) async {
    return await _faceDetector.processImage(inputImage);
  }

  InputImage? convertCameraImage({
    required CameraImage image,
    required CameraDescription camera,
    required DeviceOrientation deviceOrientation,
  }) {
    // 1. Concatenate all planes into a single Uint8List
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    // 2. Calculate the rotation compensation
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      final orientations = {
        DeviceOrientation.portraitUp: 0,
        DeviceOrientation.landscapeLeft: 90,
        DeviceOrientation.portraitDown: 180,
        DeviceOrientation.landscapeRight: 270,
      };
    var rotationCompensation = orientations[deviceOrientation] ?? 0;
    if (camera.lensDirection == CameraLensDirection.front) {
      rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
    } else {
      rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
    }
    rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
  }

  rotation ??= InputImageRotation.rotation0deg;

  var format = InputImageFormatValue.fromRawValue(image.format.raw);
  if (format == null) {
    if (Platform.isAndroid) {
      format = InputImageFormat.nv21;
    } else if (Platform.isIOS) {
      format = InputImageFormat.bgra8888;
    }
  }
  if (format == null) return null;

  final bytesPerRow = image.planes.isNotEmpty ? image.planes[0].bytesPerRow : image.width;

  return InputImage.fromBytes(
    bytes: bytes,
    metadata: InputImageMetadata(
      size: ui.Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: bytesPerRow,
    ),
  );
  }

  void dispose() {
    _faceDetector.close();
  }
}

