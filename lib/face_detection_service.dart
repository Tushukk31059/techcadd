// import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorService {
  // Static method to check for a face in an image path
  static Future<bool> checkForFace(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);

    // Initialize the face detector with default options
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    try {
      final List<Face> faces = await faceDetector.processImage(inputImage);
      await faceDetector.close();

      // Return true if at least one face is detected
      return faces.isNotEmpty;
    } catch (e) {
      // Handle any errors during processing
      // You should handle this error in your UI widget
      await faceDetector.close();
      return false;
    }
  }
}