// ignore_for_file: depend_on_referenced_packages, prefer_typing_uninitialized_variables, avoid_print
import 'package:image/image.dart';
import 'package:collection/collection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'dart:math';

abstract class Classifier {
  late Interpreter interpreter;
  late InterpreterOptions _interpreterOptions;

  late List<int> _inputShape;
  late List<int> _outputShape;

  late TensorImage _inputImage;
  late TensorBuffer _outputBuffer;

  late TfLiteType _inputType;
  late TfLiteType _outputType;

  final String _labelsFileName = 'assets/labels.txt';

  final int _labelsLength = 1001;

  late var _probabilityProcessor;

  late List<String> labels;

  String get modelName;

  NormalizeOp get preProcessNormalizeOp;
  NormalizeOp get postProcessNormalizeOp;

  Classifier({int? numThreads}) {
    _interpreterOptions = InterpreterOptions();

    if (numThreads != null) {
      _interpreterOptions.threads = numThreads;
    }

    loadModel();
    loadLabels();
  }

  Future<void> loadModel() async {
    try {
      interpreter =
          await Interpreter.fromAsset(modelName, options: _interpreterOptions);
      print('Interpreter Created Successfully');

      _inputShape = interpreter.getInputTensor(0).shape;
      _outputShape = interpreter.getOutputTensor(0).shape;
      _inputType = interpreter.getInputTensor(0).type;
      _outputType = interpreter.getOutputTensor(0).type;

      _outputBuffer = TensorBuffer.createFixedSize(_outputShape, _outputType);
      _probabilityProcessor =
          TensorProcessorBuilder().add(postProcessNormalizeOp).build();
    } catch (e) {
      print('Unable to create interpreter, Caught Exception: ${e.toString()}');
    }
  }

  Future<void> loadLabels() async {
    labels = await FileUtil.loadLabels(_labelsFileName);
    if (labels.length == _labelsLength) {
      print('Labels loaded successfully');
    } else {
      print('Unable to load labels');
    }
  }

  TensorImage _preProcess() {
    int cropSize = min(_inputImage.height, _inputImage.width);
    return ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(cropSize, cropSize))
        .add(ResizeOp(
            _inputShape[1], _inputShape[2], ResizeMethod.NEAREST_NEIGHBOUR))
        .add(preProcessNormalizeOp)
        .build()
        .process(_inputImage);
  }

  Category predict(Image image) {
    final pres = DateTime.now().millisecondsSinceEpoch;
    _inputImage = TensorImage(_inputType);
    _inputImage.loadImage(image);
    _inputImage = _preProcess();
    final pre = DateTime.now().millisecondsSinceEpoch - pres;

    print('Time to load image: $pre ms');

    final runs = DateTime.now().millisecondsSinceEpoch;
    interpreter.run(_inputImage.buffer, _outputBuffer.getBuffer());
    final run = DateTime.now().millisecondsSinceEpoch - runs;

    print('Time to run inference: $run ms');

    Map<String, double> labeledProb = TensorLabel.fromList(
            labels, _probabilityProcessor.process(_outputBuffer))
        .getMapWithFloatValue();
    final pred = getTopProbability(labeledProb);

    return Category(pred.key, pred.value);
  }

  void close() {
    interpreter.close();
  }
}

MapEntry<String, double> getTopProbability(Map<String, double> labeledProb) {
  var pq = PriorityQueue<MapEntry<String, double>>(compare);
  pq.addAll(labeledProb.entries);

  return pq.first;
}

int compare(MapEntry<String, double> e1, MapEntry<String, double> e2) {
  if (e1.value > e2.value) {
    return -1;
  } else if (e1.value == e2.value) {
    return 0;
  } else {
    return 1;
  }
}

// Abstract Class:
//
// abstract class Classifier : This declares an abstract class named Classifier. Abstract classes cannot be instantiated directly, but they can be extended by subclasses that implement the abstract methods.
// Member Variables:
//
// Interpreter interpreter: This variable will hold the loaded TensorFlow Lite interpreter instance.
// InterpreterOptions _interpreterOptions: This stores options used for interpreter creation (e.g., number of threads).
// List<int> _inputShape, _outputShape: These lists store the input and output shapes of the TensorFlow Lite model.
// TensorImage _inputImage: This represents the image to be classified after preprocessing.
// TensorBuffer _outputBuffer: This holds the output tensor from the interpreter.
// TfLiteType _inputType, _outputType: These variables store the data types of the input and output tensors.
// String _labelsFileName: This specifies the filename containing the class labels (assumed to be in assets folder).
// int _labelsLength: This defines the expected number of labels in the labels file.
// var _probabilityProcessor: This holds a processor for post-processing the output probabilities.
// List<String> labels: This list stores the loaded class labels.
// Abstract Property:
//
// String get modelName: This is an abstract getter that subclasses must implement to specify the model name (asset path) used for classification.
// Abstract Methods:
//
// NormalizeOp get preProcessNormalizeOp: This is an abstract getter that subclasses must implement to define the pre-processing normalization operation applied to the input image.
// NormalizeOp get postProcessNormalizeOp: This is an abstract getter that subclasses must implement to define the post-processing normalization operation applied to the classification probabilities.
// Constructor:
//
// Classifier({int? numThreads}): This is the constructor for the Classifier class. It takes an optional numThreads argument to specify the number of threads to use for interpreter execution.
// Methods:
//
// Future<void> loadModel() async: This method asynchronously loads the TensorFlow Lite model from the specified modelName. It also retrieves the input and output shapes, data types, and creates the output buffer and probability processor.
// Future<void> loadLabels() async: This method asynchronously loads the class labels from the specified _labelsFileName. It verifies if the loaded labels match the expected length.
// TensorImage _preProcess(): This method pre-processes the input image. It resizes the image and applies the normalization operations defined by the preProcessNormalizeOp getter.
// Category predict(Image image): This is the main classification function. It takes an Image object as input. Here's the breakdown of its steps:
// Pre-process the image using _preProcess().
// Run the TensorFlow Lite interpreter with the pre-processed image.
// Post-process the output probabilities using the _probabilityProcessor.
// Find the category with the highest probability using getTopProbability.
// Return a Category object containing the predicted class label and its probability.
// void close(): This method closes the TensorFlow Lite interpreter.
// Helper Functions:
//
// MapEntry<String, double> getTopProbability(Map<String, double> labeledProb): This function takes a map of labels and their corresponding probabilities. It uses a priority queue to find the entry with the highest probability and returns it as a MapEntry.
// int compare(MapEntry<String, double> e1, MapEntry<String, double> e2): This is a comparator function used by the priority queue in getTopProbability. It compares two MapEntry objects based on their probability values, returning -1 if e1 has higher probability, 0 if they are equal, and 1 otherwise.
// Overall, this code provides a foundation for building image classification applications using TensorFlow Lite in Flutter. Subclasses need to implement the abstract methods to define the specific model and pre-processing/post-processing operations.