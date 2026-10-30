import 'dart:io';
import 'dart:ui' as ui;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

enum LivenessState {
  noFace,
  invalidFace,
  blinkPrompt,
  blinkClosed,
  livenessVerified,
}

class LivenessResult {
  final LivenessState state;
  final String prompt;
  final Face? detectedFace;

  const LivenessResult({
    required this.state,
    required this.prompt,
    this.detectedFace,
  });
}

class LivenessDetector {
  final double minFaceSizeRatio;
  final double maxCenteringOffsetRatio;
  final double eyeClosedThreshold;
  final double eyeOpenThreshold;

  LivenessState _state = LivenessState.noFace;
  String _prompt = "Align your face in the oval frame";
  int _alignedFrameCount = 0;
  static const int _steadyHoldFramesRequired = 10;

  LivenessDetector({
    this.minFaceSizeRatio = 0.18,
    this.maxCenteringOffsetRatio = 0.30,
    this.eyeClosedThreshold = 0.25,
    this.eyeOpenThreshold = 0.55,
  });

  LivenessState get state => _state;
  String get prompt => _prompt;

  void reset() {
    _state = LivenessState.noFace;
    _prompt = "Align your face in the oval frame";
    _alignedFrameCount = 0;
  }

  LivenessResult processFrame(
    List<Face> faces,
    double rotatedWidth,
    double rotatedHeight,
  ) {
    if (faces.isEmpty) {
      _state = LivenessState.noFace;
      _prompt = "Please look at the camera";
      return LivenessResult(state: _state, prompt: _prompt);
    }

    if (faces.length > 1) {
      _state = LivenessState.invalidFace;
      _prompt = "Multiple faces detected. Ensure only one person is in frame.";
      return LivenessResult(state: _state, prompt: _prompt, detectedFace: faces.first);
    }

    final face = faces.first;

    // Coordinate rotation compensation for iOS
    ui.Rect boundingBox = face.boundingBox;
    if (Platform.isIOS) {
      boundingBox = ui.Rect.fromLTRB(
        rotatedWidth - face.boundingBox.bottom,
        face.boundingBox.left,
        rotatedWidth - face.boundingBox.top,
        face.boundingBox.right,
      );
    }

    final double faceWidth = boundingBox.width;
    final double faceHeight = boundingBox.height;

    // 1. Boundary checking (must not be clipped)
    if (boundingBox.left < 0 ||
        boundingBox.top < 0 ||
        boundingBox.right > rotatedWidth ||
        boundingBox.bottom > rotatedHeight) {
      _state = LivenessState.invalidFace;
      _prompt = "Keep your entire face within the frame";
      return LivenessResult(state: _state, prompt: _prompt, detectedFace: face);
    }

    // 2. Minimum face size (close enough)
    if (faceWidth < rotatedWidth * minFaceSizeRatio ||
        faceHeight < rotatedHeight * minFaceSizeRatio) {
      _state = LivenessState.invalidFace;
      _prompt = "Move a little closer to the camera";
      return LivenessResult(state: _state, prompt: _prompt, detectedFace: face);
    }

    // 3. Viewfinder Centering
    final faceCenter = boundingBox.center;
    final imgCenter = ui.Offset(rotatedWidth / 2, rotatedHeight / 2);
    if ((faceCenter.dx - imgCenter.dx).abs() > rotatedWidth * maxCenteringOffsetRatio ||
        (faceCenter.dy - imgCenter.dy).abs() > rotatedHeight * maxCenteringOffsetRatio) {
      _state = LivenessState.invalidFace;
      _prompt = "Center your face inside the oval";
      return LivenessResult(state: _state, prompt: _prompt, detectedFace: face);
    }

    // 4. Head Pose angles (ensure looking straight, not turned)
    final double yaw = face.headEulerAngleY ?? 0;
    final double roll = face.headEulerAngleZ ?? 0;
    if (yaw.abs() > 25 || roll.abs() > 25) {
      _alignedFrameCount = 0;
      _state = LivenessState.invalidFace;
      _prompt = "Look straight directly into the camera";
      return LivenessResult(state: _state, prompt: _prompt, detectedFace: face);
    }

    _alignedFrameCount++;

    final leftOpen = face.leftEyeOpenProbability;
    final rightOpen = face.rightEyeOpenProbability;

    // 5. If eye classification probabilities are not supported by sensor or user holds steadily:
    if (leftOpen == null || rightOpen == null || _alignedFrameCount >= _steadyHoldFramesRequired) {
      _state = LivenessState.livenessVerified;
      _prompt = "Face aligned! Capturing...";
      return LivenessResult(state: _state, prompt: _prompt, detectedFace: face);
    }

    // 6. Blink sequence verification
    if (_state == LivenessState.noFace || _state == LivenessState.invalidFace) {
      _state = LivenessState.blinkPrompt;
      _prompt = "Please blink your eyes naturally";
    } else if (_state == LivenessState.blinkPrompt) {
      if (leftOpen < eyeClosedThreshold && rightOpen < eyeClosedThreshold) {
        _state = LivenessState.blinkClosed;
        _prompt = "Now open your eyes";
      }
    } else if (_state == LivenessState.blinkClosed) {
      if (leftOpen > eyeOpenThreshold && rightOpen > eyeOpenThreshold) {
        _state = LivenessState.livenessVerified;
        _prompt = "Liveness verified! Capturing...";
      }
    }

    return LivenessResult(state: _state, prompt: _prompt, detectedFace: face);
  }
}

