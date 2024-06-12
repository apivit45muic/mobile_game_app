import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class CameraView extends StatefulWidget {
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  bool _isDetecting = false;
  final PoseDetector poseDetector = PoseDetector(options: PoseDetectorOptions());

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.high);
    await _controller.initialize();
    setState(() {});

    _controller.startImageStream((CameraImage image) {
      if (_isDetecting) return;

      _isDetecting = true;
      _detectPoses(image);
    });
  }

  Future<void> _detectPoses(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotationValue.fromRawValue(_controller.description.sensorOrientation) ?? InputImageRotation.rotation0deg,
        format: InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );

    final List<Pose> poses = await poseDetector.processImage(inputImage);

    for (Pose pose in poses) {
      // Detect ASL alphabets A, B, C
      final letterA = _isAlphabetA(pose.landmarks);
      final letterB = _isAlphabetB(pose.landmarks);
      final letterC = _isAlphabetC(pose.landmarks);

      if (letterA) {
        print("Detected: A");
        // Do something when A is detected
      } else if (letterB) {
        print("Detected: B");
        // Do something when B is detected
      } else if (letterC) {
        print("Detected: C");
        // Do something when C is detected
      }
    }

    _isDetecting = false;
  }

  bool _isAlphabetA(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    PoseLandmark? wrist = landmarks[PoseLandmarkType.leftWrist] ?? landmarks[PoseLandmarkType.rightWrist];
    PoseLandmark? thumb = landmarks[PoseLandmarkType.leftThumb] ?? landmarks[PoseLandmarkType.rightThumb];
    PoseLandmark? indexFinger = landmarks[PoseLandmarkType.leftIndex] ?? landmarks[PoseLandmarkType.rightIndex];
    if (thumb != null && indexFinger != null && wrist != null) {
      return thumb.y > wrist.y && indexFinger.y < wrist.y;
    }
    return false; // Placeholder, implement your logic
  }

  bool _isAlphabetB(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    // Logic to determine if alphabet B is detected
    return false; // Placeholder, implement your logic
  }

  bool _isAlphabetC(Map<PoseLandmarkType, PoseLandmark> landmarks) {
    // Logic to determine if alphabet C is detected
    return false; // Placeholder, implement your logic
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    return CameraPreview(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    poseDetector.close();
    super.dispose();
  }
}
