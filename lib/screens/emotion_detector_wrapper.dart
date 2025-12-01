// lib/emotion_detector_wrapper.dart
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'emotion_service.dart';

class EmotionDetectorWrapper extends StatefulWidget {
  final Widget child;
  const EmotionDetectorWrapper({super.key, required this.child});

  @override
  State<EmotionDetectorWrapper> createState() => _EmotionDetectorWrapperState();
}

class _EmotionDetectorWrapperState extends State<EmotionDetectorWrapper> {
  CameraController? _controller;
  bool _isProcessing = false;

  // VARIABLES DE DIAGNÓSTICO
  String _debugStatus = "Iniciando...";
  Color _statusColor = Colors.white;

  DateTime _lastScanTime = DateTime.now();

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableTracking: false,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          _debugStatus = "ERROR: No hay cámaras";
          _statusColor = Colors.red;
        });
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();

      if (mounted) {
        _controller!.startImageStream(_processCameraImage);
        setState(() {
          _debugStatus = "Cámara OK. Esperando...";
          _statusColor = Colors.blue;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _debugStatus = "ERROR CÁMARA:\n$e";
          _statusColor = Colors.red;
        });
      }
    }
  }

  void _processCameraImage(CameraImage image) async {
    final now = DateTime.now();
    if (_isProcessing || now.difference(_lastScanTime).inSeconds < 5) {
      return;
    }

    _isProcessing = true;
    _lastScanTime = now;

    if (mounted) {
      setState(() {
        _debugStatus = " Analizando...";
        _statusColor = Colors.yellow;
      });
    }

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final face = faces.first;
        final double? smileProb = face.smilingProbability;

        if (smileProb != null) {
          EmotionService.updateEmotion(smileProb);

          String estado = smileProb < 0.15 ? "TRISTE 😔" : "FELIZ 😃";

          if (mounted) {
            setState(() {
              _debugStatus = "✅ $estado (${(smileProb * 100).toInt()}%)";
              _statusColor = smileProb < 0.15 ? Colors.orange : Colors.green;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _debugStatus = "⚠️ No veo caras";
            _statusColor = Colors.grey;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _debugStatus = "Error ML: $e";
          _statusColor = Colors.red;
        });
      }
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: widget.child),
        Positioned(
          bottom: 150,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _statusColor, width: 2),
            ),
            child: Text(
              _debugStatus,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    final camera = _controller!.description;
    final sensorOrientation = camera.sensorOrientation;

    final rotation = InputImageRotationValue.fromRawValue(sensorOrientation) ??
        InputImageRotation.rotation0deg;

    final format = InputImageFormatValue.fromRawValue(image.format.raw) ??
        InputImageFormat.nv21;

    if (format != InputImageFormat.nv21 &&
        format != InputImageFormat.bgra8888) {
      return null;
    }

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final size = Size(image.width.toDouble(), image.height.toDouble());

    final inputImageMetadata = InputImageMetadata(
      size: size,
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: inputImageMetadata);
  }
}
