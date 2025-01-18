# AizoTF - TFLite Model Tester

Welcome to the AizoTF! This Flutter-based mobile application allows users to upload and test TensorFlow Lite (TFLite) models to ensure compatibility with mobile devices. The app currently supports **SSD MobileNet models** for both **image classification** and **object detection** tasks.

---

## Demo
Click [here](https://appetize.io/app/b_cbzngsphkxfsu5uqhmz2jmfnea) to go to Apptizer demo.

## Features

- **Upload Custom TFLite Models**: Users can upload their `.tflite` model files directly into the app.
- **Upload Label Files**: Accompanying label files can also be uploaded for enhanced testing.
- **Compatibility Testing**: Verify whether the model works seamlessly on mobile devices.
- **Support for SSD MobileNet**: Focused compatibility with SSD MobileNet models.
- **Image Classification**: Test models designed for classifying images into predefined categories.
- **Object Detection**: Evaluate models that detect and locate objects within an image.

---

## Requirements

To run the application, ensure the following prerequisites are met:

- **Flutter SDK**: Version 3.0 or higher
- **Dart SDK**: Compatible with Flutter SDK
- **Mobile Device**: Running Android 8.0 (Oreo) or later, or iOS 12.0 or later

---

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/DilukM/aizotf.git
   ```
2. Navigate to the project directory:
   ```bash
   cd aizotf
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

---

## Usage

1. Launch the application on your mobile device.
2. Navigate to the upload section.
3. Upload your `.tflite` model file.
4. Upload the corresponding label file.
5. Select the type of model:
   - **Image Classification**
   - **Object Detection**
6. Test the model by providing sample inputs.
7. View the results and debug compatibility issues if necessary.

---

## Limitations

- Currently supports only **SSD MobileNet models**.
- Only **image classification** and **object detection** are supported.
- Ensure the uploaded files adhere to TensorFlow Lite's model format and specifications.

---

## Roadmap

Planned features for future updates:

- Expand support to other model architectures.
- Add functionality for benchmarking model performance.
- Improve UI/UX for enhanced user experience.
- Add support for other types of TFLite tasks, such as natural language processing and audio recognition.

---

## Contributing

We welcome contributions! To contribute:

1. Fork the repository.
2. Create a new branch for your feature or bug fix:
   ```bash
   git checkout -b feature-name
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add a new feature"
   ```
4. Push to your fork:
   ```bash
   git push origin feature-name
   ```
5. Submit a pull request.

---


## Contact

If you have any questions or need assistance, feel free to reach out:

- **Email**: dilukedu@gmail.com
- **GitHub**: [Diluk Mihiranga](https://github.com/DilukM)

---

Thank you for using TFLite Model Tester! We hope this tool helps you optimize and validate your TFLite models effortlessly.

