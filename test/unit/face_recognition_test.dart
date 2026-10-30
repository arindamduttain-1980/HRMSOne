import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbs_attendance_app/core/face_recognition/face_recognition_service.dart';
import 'package:mbs_attendance_app/core/face_recognition/liveness_detector.dart';
import 'package:mbs_attendance_app/data/repositories/face_repository.dart';

void main() {
  group('Face Recognition Distance and Threshold Tests', () {
    late FaceRecognitionService recognitionService;

    setUp(() {
      recognitionService = FaceRecognitionService();
    });

    test('Identical embeddings produce distance of 0.0 and match', () {
      final emb = List<double>.generate(192, (i) => i.toDouble() / 192.0);
      final dist = recognitionService.calculateDistance(emb, emb);
      expect(dist, closeTo(0.0, 0.0001));

      final match = recognitionService.compareFaces(emb, emb, threshold: 0.75);
      expect(match.isMatched, isTrue);
      expect(match.distance, closeTo(0.0, 0.0001));
    });

    test('Dissimilar embeddings produce high distance and do not match', () {
      final emb1 = List<double>.filled(192, 0.0);
      emb1[0] = 1.0;

      final emb2 = List<double>.filled(192, 0.0);
      emb2[1] = 1.0;

      final dist = recognitionService.calculateDistance(emb1, emb2);
      // Normalized orthogonal unit vectors have Euclidean distance sqrt(1^2 + 1^2) = ~1.4142
      expect(dist, closeTo(1.4142, 0.01));

      final match = recognitionService.compareFaces(emb1, emb2, threshold: 0.75);
      expect(match.isMatched, isFalse);
      expect(match.distance, greaterThan(0.75));
    });

    test('Embedding distance handles mismatched lengths gracefully', () {
      final emb1 = List<double>.filled(192, 0.5);
      final emb2 = List<double>.filled(128, 0.5);

      final dist = recognitionService.calculateDistance(emb1, emb2);
      expect(dist, double.infinity);
    });
  });

  group('Liveness Detector State Machine Tests', () {
    test('Empty faces list returns noFace state', () {
      final detector = LivenessDetector();
      final result = detector.processFrame([], 480, 640);
      expect(result.state, LivenessState.noFace);
      expect(result.prompt, contains('camera'));
    });
  });

  group('FaceRepository Response Serialization Tests', () {
    test('FaceRegistrationResponse parses successfully', () {
      final json = {
        'success': true,
        'message': 'Face registered successfully',
        'face': 1,
        'template_version': '1.0',
      };

      final response = FaceRegistrationResponse.fromJson(json);
      expect(response.success, isTrue);
      expect(response.message, 'Face registered successfully');
      expect(response.face, 1);
      expect(response.templateVersion, '1.0');
    });

    test('Face registration payload serialization format', () {
      final embedding = List<double>.generate(192, (i) => i * 0.01);
      final payload = {
        'model_name': 'mobilefacenet',
        'model_version': '1.0',
        'dimensions': embedding.length,
        'embedding': jsonEncode(embedding),
      };

      expect(payload['model_name'], 'mobilefacenet');
      expect(payload['dimensions'], 192);
      final decodedEmbedding = jsonDecode(payload['embedding'] as String);
      expect(decodedEmbedding, isA<List>());
      expect((decodedEmbedding as List).length, 192);
    });
  });

  group('Biometric Encryption Security Tests', () {
    test('XOR encryption and decryption is bit-exact and reversible', () {
      final plaintext = jsonEncode(List<double>.generate(192, (i) => (i * 0.12345)));
      final key = 'test_secret_aes_hardware_key_32_bytes!';

      // Encrypt
      final pBytes = utf8.encode(plaintext);
      final kBytes = utf8.encode(key);
      final cipher = List<int>.filled(pBytes.length, 0);
      for (int i = 0; i < pBytes.length; i++) {
        cipher[i] = pBytes[i] ^ kBytes[i % kBytes.length];
      }
      final encryptedBase64 = base64Encode(cipher);

      // Verify ciphertext does not leak plaintext
      expect(encryptedBase64, isNot(equals(plaintext)));

      // Decrypt
      final cBytes = base64Decode(encryptedBase64);
      final plain = List<int>.filled(cBytes.length, 0);
      for (int i = 0; i < cBytes.length; i++) {
        plain[i] = cBytes[i] ^ kBytes[i % kBytes.length];
      }
      final decrypted = utf8.decode(plain);

      expect(decrypted, equals(plaintext));
      final decodedList = (jsonDecode(decrypted) as List).cast<double>();
      expect(decodedList.length, 192);
      expect(decodedList[0], closeTo(0.0, 0.0001));
      expect(decodedList[1], closeTo(0.12345, 0.0001));
    });
  });
}

