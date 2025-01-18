import 'package:aizotf/services/validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class SelectDetectionModel extends StatefulWidget {
  const SelectDetectionModel({super.key});

  @override
  State<SelectDetectionModel> createState() => _SelectDetectionModelState();
}

class _SelectDetectionModelState extends State<SelectDetectionModel> {
  late SharedPreferences prefs;

  String? _tfliteFilePath;
  String? _labelFilePath;

  @override
  void initState() {
    super.initState();
    _loadFilePath();
  }

  Future<void> _loadFilePath() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _tfliteFilePath = prefs.getString('ODtfliteFilePath');
      _labelFilePath = prefs.getString('ODlabelFilePath');
    });
  }

  Future<void> _pickTfliteFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      String? filePath = result.files.single.path;

      if (filePath != null && filePath.endsWith('.tflite')) {
        prefs = await SharedPreferences.getInstance();
        await prefs.setString('ODtfliteFilePath', filePath);
        await prefs.setBool('useCustomModel', true);

        setState(() {
          _tfliteFilePath = filePath;
        });
      } else {
        toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          context: context,
          title: Text('Please select a valid .tflite file.'),
          autoCloseDuration: const Duration(seconds: 2),
        );
      }
    }
  }

  Future<void> _clearTfliteFilePath() async {
    prefs = await SharedPreferences.getInstance();
    await prefs.remove('ODtfliteFilePath');
    await prefs.setBool('useCustomModel', false);
    setState(() {
      _tfliteFilePath = null;
    });
  }

  Future<void> _clearLabelFilePath() async {
    prefs = await SharedPreferences.getInstance();
    await prefs.remove('ODlabelFilePath');
    await prefs.setBool('useCustomLabel', false);
    setState(() {
      _labelFilePath = null;
    });
  }

  Future<void> _loadLabelFilePath() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _labelFilePath = prefs.getString('ODlabelFilePath');
    });
  }

  Future<void> _pickLabelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      String? filePath = result.files.single.path;

      if (filePath != null && filePath.endsWith('.txt')) {
        prefs = await SharedPreferences.getInstance();
        await prefs.setString('ODlabelFilePath', filePath);
        await prefs.setBool('useCustomLabel', true);

        setState(() {
          _labelFilePath = filePath;
        });
      } else {
        toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          context: context,
          title: Text('Please select a valid .txt file.'),
          autoCloseDuration: const Duration(seconds: 2),
        );
      }
    }
  }

  void _onContinue() async {
    final validator = Validator(context: context);

    final isValid = await validator.validateAndNavigate(
      labelFilePath: _labelFilePath,
      modelFilePath: _tfliteFilePath,
      onValidationSuccess: () async {
        // Navigate to the next page
        Navigator.pushNamed(context, '/object');
      },
    );

    if (!isValid) {
      // Optionally handle additional actions on validation failure
      print("Validation failed. Please resolve the issues.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            )),
        backgroundColor: Colors.grey[900],
        title: Text(
          "Select Model",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(children: [
          //Model Picker widget
          Container(
            padding: EdgeInsets.all(12),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8)),
            child: _tfliteFilePath != null
                ? Column(
                    children: [
                      Stack(
                        alignment: AlignmentDirectional.topEnd,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage('assets/selected.png'),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _pickTfliteFile,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      Color.fromARGB(255, 1, 237, 25),
                                      Color.fromARGB(255, 134, 253, 140),
                                    ],
                                    tileMode: TileMode.mirror,
                                  )),
                              child: Text(
                                "Change Model",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        ],
                      ),
                      Text(
                        "Model Selected",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: _pickTfliteFile,
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.2,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage(
                                      'assets/image_placeholder.png'))),
                        ),
                        Text(
                          "Select a model file",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
          ),
          SizedBox(
            height: 20,
          ),

          //Label Picker WIdget
          Container(
            padding: EdgeInsets.all(12),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8)),
            child: _labelFilePath != null
                ? Column(
                    children: [
                      Stack(
                        alignment: AlignmentDirectional.topEnd,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.2,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage('assets/selected.png'))),
                          ),
                          GestureDetector(
                            onTap: _pickLabelFile,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      Color.fromARGB(255, 1, 237, 25),
                                      Color.fromARGB(255, 134, 253, 140),
                                    ],
                                    tileMode: TileMode.mirror,
                                  )),
                              child: Text(
                                "Change Label",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        ],
                      ),
                      Text(
                        "Label Selected",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: _pickLabelFile,
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.2,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage(
                                      'assets/image_placeholder.png'))),
                        ),
                        Text(
                          "Select a label file",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
          ),
          Expanded(
            child: SizedBox(),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: GestureDetector(
              onTap: _onContinue,
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    gradient: LinearGradient(
                      colors: <Color>[
                        Color.fromARGB(255, 1, 237, 25),
                        Color.fromARGB(255, 134, 253, 140),
                      ],
                      tileMode: TileMode.mirror,
                    )),
                child: Text(
                  "Continue",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
