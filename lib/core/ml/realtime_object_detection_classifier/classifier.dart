// ignore_for_file: avoid_print, depend_on_referenced_packages, unnecessary_null_comparison

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import '/core/ml/realtime_object_detection_classifier/recognition.dart';

import 'stats.dart';

/// Classifier
class Classifier {
  /// Instance of Interpreter
  late Interpreter _interpreter;


  /// Labels file loaded as list
  late List<String> _labels;

  static const String modelFileName = "detect.tflite";
  static const String labelFileName = "labelmap.txt";

  /// Input size of image (height = width = 300)
  static const int inputSize = 300;

  /// Result score threshold
  static const double threshold = 0.5;

  /// [ImageProcessor] used to pre-process the image
  ImageProcessor? imageProcessor;

  /// Padding the image to transform into square
  late int padSize;

  /// Shapes of output tensors
  late List<List<int>> _outputShapes;

  /// Types of output tensors
  late List<TfLiteType> _outputTypes;

  /// Number of results to show
  static const int numResult = 10;

  Classifier({
    Interpreter? interpreter,
    List<String>? labels,
  }) {
    _initializeInterpreter(interpreter: interpreter);
    loadModel(interpreter: interpreter);
    loadLabels(labels: labels);
  }

  Future<void> _initializeInterpreter({Interpreter? interpreter}) async {
    try {
      _interpreter = interpreter ??
          await Interpreter.fromAsset(
            modelFileName,
            options: InterpreterOptions()..threads = 4,
          );

      var outputTensors = _interpreter.getOutputTensors();
      _outputShapes = [];
      _outputTypes = [];
      for (var tensor in outputTensors) {
        _outputShapes.add(tensor.shape);
        _outputTypes.add(tensor.type);
      }
    } catch (e) {
      print("Error while creating interpreter: $e");
    }
  }

  /// Loads interpreter from asset
  void loadModel({Interpreter? interpreter}) async {
    try {
      _interpreter = interpreter ??
          await Interpreter.fromAsset(
            modelFileName,
            options: InterpreterOptions()..threads = 4,
          );

      var outputTensors = _interpreter.getOutputTensors();
      _outputShapes = [];
      _outputTypes = [];
      for (var tensor in outputTensors) {
        _outputShapes.add(tensor.shape);
        _outputTypes.add(tensor.type);
      }
    } catch (e) {
      print("Error while creating interpreter: $e");
    }
  }

  /// Loads labels from assets
  void loadLabels({List<String>? labels}) async {
    try {
      _labels =
          labels ?? await FileUtil.loadLabels("assets/$labelFileName");
    } catch (e) {
      print("Error while loading labels: $e");
    }
  }

  /// Pre-process the image
  TensorImage getProcessedImage(TensorImage inputImage) {
    padSize = max(inputImage.height, inputImage.width);
    imageProcessor ??= ImageProcessorBuilder()
          .add(ResizeWithCropOrPadOp(padSize, padSize))
          .add(ResizeOp(inputSize, inputSize, ResizeMethod.BILINEAR))
          .build();
    inputImage = imageProcessor!.process(inputImage);
    return inputImage;
  }

  /// Runs object detection on the input image
  Map<String, dynamic>? predict(image_lib.Image image) {
    var predictStartTime = DateTime.now().millisecondsSinceEpoch;

    if (_interpreter == null) {
      print("Interpreter not initialized");
      return null;
    }

    var preProcessStart = DateTime.now().millisecondsSinceEpoch;

    // Create TensorImage from image
    TensorImage inputImage = TensorImage.fromImage(image);

    // Pre-process TensorImage
    inputImage = getProcessedImage(inputImage);

    var preProcessElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preProcessStart;

    // TensorBuffers for output tensors
    TensorBuffer outputLocations = TensorBufferFloat(_outputShapes[0]);
    TensorBuffer outputClasses = TensorBufferFloat(_outputShapes[1]);
    TensorBuffer outputScores = TensorBufferFloat(_outputShapes[2]);
    TensorBuffer numLocations = TensorBufferFloat(_outputShapes[3]);

    // Inputs object for runForMultipleInputs
    // Use [TensorImage.buffer] or [TensorBuffer.buffer] to pass by reference
    List<Object> inputs = [inputImage.buffer];

    // Outputs map
    Map<int, Object> outputs = {
      0: outputLocations.buffer,
      1: outputClasses.buffer,
      2: outputScores.buffer,
      3: numLocations.buffer,
    };

    var inferenceTimeStart = DateTime.now().millisecondsSinceEpoch;

    // run inference
    _interpreter.runForMultipleInputs(inputs, outputs);

    var inferenceTimeElapsed =
        DateTime.now().millisecondsSinceEpoch - inferenceTimeStart;

    // Maximum number of results to show
    int resultsCount = min(numResult, numLocations.getIntValue(0));

    // Using labelOffset = 1 as ??? at index 0
    int labelOffset = 1;

    // Using bounding box utils for easy conversion of tensorbuffer to List<Rect>
    List<Rect> locations = BoundingBoxUtils.convert(
      tensor: outputLocations,
      valueIndex: [1, 0, 3, 2],
      boundingBoxAxis: 2,
      boundingBoxType: BoundingBoxType.BOUNDARIES,
      coordinateType: CoordinateType.RATIO,
      height: inputSize,
      width: inputSize,
    );

    List<Recognition> recognitions = [];

    for (int i = 0; i < resultsCount; i++) {
      // Prediction score
      var score = outputScores.getDoubleValue(i);

      // Label string
      var labelIndex = outputClasses.getIntValue(i) + labelOffset;
      var label = _labels.elementAt(labelIndex);

      if (score > threshold) {
        // inverse of rect
        // [locations] corresponds to the image size 300 X 300
        // inverseTransformRect transforms it our [inputImage]
        Rect transformedRect = imageProcessor!.inverseTransformRect(
            locations[i], image.height, image.width);

        recognitions.add(
          Recognition(i, label, score, transformedRect),
        );
      }
    }

    var predictElapsedTime =
        DateTime.now().millisecondsSinceEpoch - predictStartTime;

    return {
      "recognitions": recognitions,
      "stats": Stats(
          totalPredictTime: predictElapsedTime,
          inferenceTime: inferenceTimeElapsed,
          preProcessingTime: preProcessElapsedTime)
    };
  }

  /// Gets the interpreter instance
  Interpreter get interpreter => _interpreter;

  /// Gets the loaded labels
  List<String> get labels => _labels;
}




//
// This code defines a Classifier class for real-time object detection using TensorFlow Lite in Flutter. Here's a breakdown of its functionalities:
//
// Class:
//
// Classifier: This class handles object detection tasks using a TensorFlow Lite model.
// Member Variables:
//
// Interpreter _interpreter: This variable holds the loaded TensorFlow Lite interpreter instance.
// List<String> _labels: This list stores the loaded class labels for detected objects.
// Static Constants:
//
// modelFileName: This specifies the filename of the TensorFlow Lite object detection model (assumed to be in assets folder).
// labelFileName: This specifies the filename of the file containing class labels (assumed to be in assets folder).
// inputSize: This defines the expected input image size (height and width) for the model.
// threshold: This sets the minimum confidence score required for a detection to be considered valid.
// numResult: This defines the maximum number of detections to be returned by the predict function.
// Constructor:
//
// Classifier({Interpreter? interpreter, List<String>? labels}): This constructor takes optional arguments for pre-initializing the interpreter and labels.
// Methods:
//
// _initializeInterpreter({Interpreter? interpreter}) async: This method asynchronously initializes the TensorFlow Lite interpreter. It retrieves the output tensor shapes and data types.
// loadModel({Interpreter? interpreter}) async: This method (with a slightly misleading name) also initializes the interpreter if not provided in the constructor. It retrieves the output tensor shapes and data types.
// loadLabels({List<String>? labels}) async: This method asynchronously loads the class labels from the specified labelFileName.
// TensorImage getProcessedImage(TensorImage inputImage): This method pre-processes the input image. It resizes the image to a square shape based on inputSize and applies padding if necessary.
// Map<String, dynamic>? predict(image_lib.Image image): This is the main object detection function. Here's a breakdown of its steps:
// Checks if the interpreter is initialized.
// Gets the current time for performance measurement.
// Creates a TensorImage object from the input image.
// Pre-processes the TensorImage using getProcessedImage.
// Creates TensorBuffer objects for the expected output tensors (locations, classes, scores, and number of detections).
// Prepares input and output objects for the interpreter's runForMultipleInputs method.
// Runs object detection inference using the interpreter.
// Calculates time spent on pre-processing and inference.
// Processes the output tensors:
// Extracts bounding box locations.
// Converts scores and class indices to labels.
// Filters detections based on the threshold.
// Applies inverse transformation to bounding boxes to adjust for pre-processing.
// Creates a list of Recognition objects containing detected object information (label, score, and bounding box).
// Creates a Stats object to store performance metrics (total prediction time, inference time, and pre-processing time).
// Returns a map containing the list of detections and performance statistics.
// Interpreter get interpreter => _interpreter: This getter method provides access to the internal interpreter instance.
// List<String> get labels => _labels: This getter method provides access to the loaded class labels.
// Overall, this Classifier class provides a well-structured implementation for real-time object detection using TensorFlow Lite in Flutter. It handles model loading, label loading, pre-processing, inference, and post-processing to deliver a list of detected objects with their labels, scores, and bounding boxes. The Stats object allows for monitoring the performance of the object detection process.