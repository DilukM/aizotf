import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart'; // Ensure you're importing the required package

class Validator {
  final BuildContext context;

  Validator({required this.context});

  Future<bool> validateAndNavigate({
    required String? labelFilePath,
    required String? modelFilePath,
    required VoidCallback onValidationSuccess,
  }) async {
    // List of validation checks and corresponding error messages
    final validations = [
      {
        'condition': labelFilePath == null,
        'message': 'Please pick a label file to continue.',
      },
      {
        'condition': modelFilePath == null,
        'message': 'Please pick a model file to continue.',
      },
    ];

    // Loop through validations and show the first error message if any
    for (var validation in validations) {
      if (validation['condition'] as bool) {
        toastification.show(
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          context: context,
          title: Text(validation['message'] as String),
          autoCloseDuration: const Duration(seconds: 2),
        );
        return false; // Validation failed
      }
    }

    // If all validations pass
    onValidationSuccess();
    return true;
  }
}
