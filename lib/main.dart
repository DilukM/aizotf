import 'package:aizotf/Pages/SplashScreen.dart';
import 'package:aizotf/Pages/customDetectionModel.dart';
import 'package:aizotf/Pages/customModel.dart';
import 'package:aizotf/Pages/imageProcessingPage.dart';
import 'package:aizotf/Pages/Home.dart';
import 'package:aizotf/Pages/ObjectDetection.dart';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'Theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(
            ChangeNotifierProvider(
              create: (context) => ThemeProvider(),
              child: App(camera: firstCamera),
            ),
          ));
}

class App extends StatelessWidget {
  final CameraDescription camera;
  const App({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Model Tester',
      theme: Provider.of<ThemeProvider>(context).themeData,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/redhome': (context) => RedHome(),
        '/red': (context) => Red(camera: camera),
        '/object': (context) => ObjectDetection(camera: camera),
        '/selectModel': (context) => SelectModel(),
        '/ObjectSelectModel': (context) => SelectDetectionModel(),
      },
    );
  }
}
