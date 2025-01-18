import 'package:camera/camera.dart';
import 'package:aizotf/util/shape.dart';
import 'package:flutter/material.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class Red extends StatefulWidget {
  final CameraDescription camera;
  const Red({super.key, required this.camera});

  @override
  State<Red> createState() => _RedState();
}

class _RedState extends State<Red> {
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;

  String label = '';
  double confidence = 0.0;
  bool _isProcessing = false; // Flag for processing
  bool _isProcessingPaused = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      _controller = CameraController(widget.camera, ResolutionPreset.high);
      _initializeControllerFuture = _controller.initialize().then((_) async {
        await _tfLiteInit();
        if (!_isProcessingPaused) {
          await _startStreaming();
        }
      });
    });
  }

  Future<void> _tfLiteInit() async {
    String modelPath =
        _prefs.getString('tfliteFilePath') ?? 'assets/detect.tflite';
    String labelPath =
        _prefs.getString('labelFilePath') ?? 'assets/labelmap.txt';
    try {
      await Tflite.loadModel(
        model: modelPath,
        labels: labelPath,
        numThreads: 1,
        isAsset: false,
        useGpuDelegate: false,
      );
    } catch (e) {
      Navigator.pop(context);
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        context: context,
        title: Text('Error during model loading: $e'),
        autoCloseDuration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _startStreaming() async {
    try {
      await _controller.startImageStream((CameraImage image) {
        if (!_isProcessing) {
          _processImage(image);
        }
      });
    } catch (e) {
      Navigator.pop(context);
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        context: context,
        title: Text('Error during image streaming: $e'),
        autoCloseDuration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _processImage(CameraImage image) async {
    _isProcessing = true; // Mark processing as ongoing
    try {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        rotation: -90,
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        setState(() {
          confidence = (recognitions[0]['confidence'] ?? 0.0) * 100;
          label = recognitions[0]['label']?.toString() ?? '';
        });
      } else {
        setState(() {
          label = 'No detection';
          confidence = 0.0;
        });
      }
    } catch (e) {
      Navigator.pop(context);
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        context: context,
        title: Text('Error during image processing: $e'),
        autoCloseDuration: const Duration(seconds: 2),
      );
      debugPrint('Error processing image: $e');
    } finally {
      _isProcessing = false; // Allow next frame processing
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    Tflite.close();
    WakelockPlus.disable();
    super.dispose();
  }

  void _toggleProcessingAndNavigate(int index) {
    setState(() {
      _isProcessingPaused = true;
    });
    _controller.stopImageStream().then((_) {
      switch (index) {
        case 0:
          Navigator.pushNamed(context, '/home');
          break;
        case 1:
          Navigator.pushNamed(context, '/settings');
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    WakelockPlus.enable();
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return buildPortrait();
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget buildPortrait() => Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                CameraPreview(_controller),
                ClipPath(
                  clipper: RectangularHoleClipper(
                    holeWidth: MediaQuery.of(context).size.width * 0.65,
                    holeHeight: MediaQuery.of(context).size.width * 0.85,
                    borderRadius: 25,
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * 1.78,
                    color: Colors.black45,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: buildBottomControls(),
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
          ),
        ],
      );

  Widget buildBottomControls() => Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Label', style: TextStyle(color: Colors.white)),
                    Text(
                      '$label',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 1, 237, 32),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Confidence',
                        style: TextStyle(color: Colors.white)),
                    Text(
                      '${confidence.toInt()}%',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 1, 237, 48),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                height: 60,
                width: MediaQuery.of(context).size.width / 1.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 134, 253, 144),
                      Color.fromARGB(255, 1, 237, 21),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    _isProcessingPaused ? 'Start capturing' : 'Stop capturing',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
