import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

import 'detector_view.dart';
import 'label_detector_painter.dart';
import 'utils.dart';

class ImageLabelView extends StatefulWidget {
  const ImageLabelView({super.key});

  @override
  State<ImageLabelView> createState() => _ImageLabelViewState();
}

class _ImageLabelViewState extends State<ImageLabelView> {
  late ImageLabeler _imageLabeler;
  bool _canProcess = false;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;

  @override
  void initState() {
    super.initState();

    _initializeLabeler();
  }

  @override
  void dispose() {
    _canProcess = false;
    _imageLabeler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Image Labeler',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
    );
  }

  void _initializeLabeler() async {
    // uncomment next line if you want to use the default model
    // _imageLabeler = ImageLabeler(options: ImageLabelerOptions());

    // uncomment next lines if you want to use a local model
    // make sure to add tflite model to assets/ml
    // final path = 'assets/ml/lite-model_aiy_vision_classifier_birds_V1_3.tflite';
    // final path = 'assets/ml/object_labeler_flowers.tflite';
    const path = 'assets/ml/object_labeler.tflite';
    final modelPath = await getAssetPath(path);
    final options = LocalLabelerOptions(modelPath: modelPath);
    _imageLabeler = ImageLabeler(options: options);

    // uncomment next lines if you want to use a remote model
    // make sure to add model to firebase
    // final modelName = 'bird-classifier';
    // final response =
    //     await FirebaseImageLabelerModelManager().downloadModel(modelName);
    // print('Downloaded: $response');
    // final options =
    //     FirebaseLabelerOption(confidenceThreshold: 0.5, modelName: modelName);
    // _imageLabeler = ImageLabeler(options: options);

    _canProcess = true;
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final labels = await _imageLabeler.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = LabelDetectorPainter(labels);
      _customPaint = CustomPaint(painter: painter);
    } else {
      String text = 'Labels found: ${labels.length}\n\n';
      for (final label in labels) {
        text += 'Label: ${label.label}, '
            'Confidence: ${label.confidence.toStringAsFixed(2)}\n\n';
      }
      _text = text;
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}



// This code defines an ImageLabelView widget in Flutter that utilizes the Google ML Kit Image Labeling functionality to detect labels in images and visualize the results.  Here's a breakdown:
//
// 1. Functionality:
//
// Detects labels (objects) in captured images or images from the gallery.
// Visualizes the detected labels and their confidence scores on top of the image or as formatted text below the image.
// 2. State Management:
//
// Uses DetectorView for the core UI structure with custom paint and text display.
// Tracks internal state variables:
// _imageLabeler: The image labeler instance for processing images.
// _canProcess: Flag indicating if image processing is ready.
// _isBusy: Flag indicating if image processing is currently ongoing.
// _customPaint: Custom paint widget for label visualization (on image).
// _text: Text displayed below the image for label results (if image metadata is unavailable).
// 3. Methods:
//
// _initializeLabeler:
// Configures the _imageLabeler instance based on comments:
// Uncomment the default model option for a pre-trained model provided by Google.
// Uncomment the local model option to use a TensorFlow Lite model from your assets folder. (Requires adding the model file)
// Uncomment the remote model option to use a model downloaded from Firebase. (Requires model setup in Firebase)
// Sets _canProcess to true after successful initialization.
// _processImage(InputImage):
// Checks if processing is ready and not already busy.
// Sets _isBusy to true and clears previous text.
// Processes the image using _imageLabeler.processImage(inputImage).
// Based on image metadata availability:
// If metadata (size and rotation) is available, creates a LabelDetectorPainter and updates _customPaint for on-image visualization.
// Otherwise, creates formatted text with detected labels and confidence scores and updates _text for display below the image.
// Sets _isBusy to false after processing.
// Triggers a UI rebuild if the widget is still mounted.
// Overall, this ImageLabelView demonstrates how to integrate image labeling with Google ML Kit, handle different model loading options, and visualize the results effectively in a Flutter application.