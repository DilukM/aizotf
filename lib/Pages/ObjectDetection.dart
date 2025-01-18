import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:toastification/toastification.dart';

class ObjectDetection extends StatefulWidget {
  final CameraDescription camera;
  const ObjectDetection({super.key, required this.camera});

  @override
  _ObjectDetectionState createState() => _ObjectDetectionState();
}

class _ObjectDetectionState extends State<ObjectDetection> {
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;

  String label = '';
  double _confidence = 0.4;
  bool _isProcessingPaused = false;
  bool isInterpreterBusy = false;
  late SharedPreferences _prefs;

  List<dynamic>? _recognitions; // Detected objects with bounding boxes

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Initialize SharedPreferences
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;

      // Initialize camera controller
      _controller = CameraController(widget.camera, ResolutionPreset.high);
      _initializeControllerFuture = _controller.initialize().then((_) async {
        await _tfLiteInit();
        if (!_isProcessingPaused) {
          await _startStreaming();
        }
      });
    });
  }

//Using only for detect objects in a video
  Future<void> _startStreaming() async {
    await _controller.startImageStream((CameraImage image) {
      _processImage(image);
    });
  }

//Using only for detect objects in a video
  Future<void> _processImage(CameraImage image) async {
    if (mounted && !_isProcessingPaused) {
      if (isInterpreterBusy) {
        return;
      }
      isInterpreterBusy = true;
      try {
        final recognitions = await _detectObjectsOnFrame(image);

        // Check if recognitions are valid and not empty
        if (recognitions != null && recognitions.isNotEmpty) {
          setState(() {
            _recognitions = recognitions;
          });
        } else {
          setState(() {
            _recognitions = [];
          });
          toastification.show(
            type: ToastificationType.error,
            style: ToastificationStyle.fillColored,
            context: context,
            title: Text('No objects detected or invalid output.'),
            autoCloseDuration: const Duration(seconds: 2),
          );
        }
      } catch (e) {
        toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          context: context,
          title: Text('Error during object detection: $e'),
          autoCloseDuration: const Duration(seconds: 2),
        );
      } finally {
        isInterpreterBusy = false;
      }
    }
  }

  Future<List<dynamic>?> _detectObjectsOnFrame(CameraImage image) async {
    try {
      // Call the TFLite model
      final result = await Tflite.detectObjectOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        numResultsPerClass: 2,
        threshold: 0.4, // Adjust threshold as needed
      );

      // Check if the result is valid
      if (result != null && result.isNotEmpty) {
        return result;
      } else {
        return [];
      }
    } catch (e) {
      // Show a toast if there is an error with object detection
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        context: context,
        title: Text('Error in object detection: $e'),
        autoCloseDuration: const Duration(seconds: 2),
      );

      return []; // Return an empty list to prevent app crash
    }
  }

  Future<void> _tfLiteInit() async {
    try {
      String modelPath =
          _prefs.getString('ODtfliteFilePath') ?? 'assets/detect.tflite';
      String labelPath =
          _prefs.getString('ODlabelFilePath') ?? 'assets/labelmap.txt';

      await Tflite.loadModel(
        model: modelPath,
        labels: labelPath,
        numThreads: 1,
        isAsset: false,
      );
    } catch (e) {
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        context: context,
        title: Text('Error loading TFLite model: $e'),
        autoCloseDuration: const Duration(seconds: 2),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      CameraPreview(_controller), // Display the camera feed

                      if (_recognitions != null)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: BoundingBoxPainter(
                              _recognitions!,
                              _controller.value.previewSize!
                                  .height, // Image width from detection
                              _controller.value.previewSize!
                                  .width, // Image height from detection
                              _confidence,
                            ),
                          ),
                        ),

                      Positioned(
                        top: 40,
                        left: 10,
                        child: IconButton(
                          onPressed: () {
                            _isProcessingPaused
                                ? Navigator.pop(context)
                                : _controller.stopImageStream().then((_) {
                                    Navigator.pop(context);
                                  });
                            setState(() {
                              _isProcessingPaused = true;
                            });
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 22.0),
                          child: Text(
                            'Accuracy',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Slider(
                                inactiveColor: Colors.grey,
                                activeColor: Color.fromARGB(255, 1, 237, 13),
                                value: _confidence,
                                min: 0,
                                max: 1,
                                onChanged: (value) async {
                                  setState(() {
                                    _confidence = value;
                                  });
                                },
                              ),
                            ),
                            Text(
                              '${(_confidence * 100).toInt()}%',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_isProcessingPaused) {
                        _startStreaming();
                        setState(() {
                          _isProcessingPaused = false;
                        });
                      } else {
                        _controller.stopImageStream();

                        setState(() {
                          _isProcessingPaused = true;
                        });
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      height: 50,
                      width: MediaQuery.of(context).size.width / 1.5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment(0.8, 1),
                          colors: <Color>[
                            Color.fromARGB(255, 134, 253, 144),
                            Color.fromARGB(255, 1, 237, 21),
                          ],
                          tileMode: TileMode.mirror,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _isProcessingPaused
                              ? 'Start Detection'
                              : 'Stop Detection',
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final double _confidence;
  final List<dynamic> recognitions;
  final double imageWidth;
  final double imageHeight;

  BoundingBoxPainter(
      this.recognitions, this.imageWidth, this.imageHeight, this._confidence);

  @override
  void paint(Canvas canvas, Size size) {
    // Scale factors to adapt to the actual widget size
    double scaleX = size.width / imageWidth;
    double scaleY = size.height / imageHeight;

    for (var recognition in recognitions) {
      // Normalize bounding box coordinates
      double x = recognition['rect']['x'] * imageWidth * scaleX;
      double y = recognition['rect']['y'] * imageHeight * scaleY;
      double w = recognition['rect']['w'] * imageWidth * scaleX;
      double h = recognition['rect']['h'] * imageHeight * scaleY;

      Rect rect = Rect.fromLTWH(x, y, w, h);

      if (recognition['confidenceInClass'] >= _confidence) {
        canvas.drawRect(
          rect,
          Paint()
            ..color = Colors.red
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );

        // Display the detected class label above the bounding box
        TextSpan span = TextSpan(
          style: TextStyle(
              color: Colors.white, fontSize: 12, backgroundColor: Colors.red),
          text: recognition['detectedClass'],
        );
        TextPainter textPainter = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
