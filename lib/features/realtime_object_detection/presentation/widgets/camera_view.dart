import 'dart:isolate';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../../../core/ml/realtime_object_detection_classifier/classifier.dart';
import '../../../../core/ml/realtime_object_detection_classifier/recognition.dart';
import '../../../../core/ml/realtime_object_detection_classifier/stats.dart';
import '../../../../core/util/isolate_util.dart';
import 'camera_view_singleton.dart';

class CameraView extends StatefulWidget {
  final Function(List<Recognition> recognitions) resultsCallback;
  final Function(Stats stats) statsCallback;

  const CameraView(this.resultsCallback, this.statsCallback, {Key? key})
      : super(key: key);

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  List<CameraDescription>? cameras;
  CameraController? cameraController;
  bool? predicting;
  Classifier? classifier;
  IsolateUtils? isolateUtils;

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  void initStateAsync() async {
    WidgetsBinding.instance!.addObserver(this);
    isolateUtils = IsolateUtils();
    await isolateUtils!.start();
    initializeCamera();
    classifier = Classifier();
    predicting = false;
  }

  void initializeCamera() async {
    cameras = await availableCameras();
    cameraController = CameraController(cameras![0], ResolutionPreset.low);
    cameraController!.initialize().then((_) async {
      await cameraController!.startImageStream(onLatestImageAvailable);
      Size? previewSize = cameraController!.value.previewSize;
      CameraViewSingleton.inputImageSize = previewSize;
      Size screenSize = MediaQuery.of(context).size;
      CameraViewSingleton.screenSize = screenSize;
      CameraViewSingleton.ratio = screenSize.width / previewSize!.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Container();
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: CameraPreview(cameraController!),
    );
  }

  onLatestImageAvailable(CameraImage cameraImage) async {
    if (classifier == null || classifier!.interpreter == null || classifier!.labels == null) {
      return;
    }

    if (predicting!) {
      return;
    }

    setState(() {
      predicting = true;
    });

    var uiThreadTimeStart = DateTime.now().millisecondsSinceEpoch;
    var isolateData = IsolateData(cameraImage, classifier!.interpreter.address,
        classifier!.labels);
    Map<String, dynamic> inferenceResults = await inference(isolateData);
    var uiThreadInferenceElapsedTime =
        DateTime.now().millisecondsSinceEpoch - uiThreadTimeStart;

    widget.resultsCallback(inferenceResults["recognitions"]);
    widget.statsCallback((inferenceResults["stats"] as Stats)
      ..totalElapsedTime = uiThreadInferenceElapsedTime);

    setState(() {
      predicting = false;
    });
  }

  Future<Map<String, dynamic>> inference(IsolateData isolateData) async {
    ReceivePort responsePort = ReceivePort();
    isolateUtils!.sendPort.send(isolateData..responsePort = responsePort.sendPort);
    var results = await responsePort.first;
    return results;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        cameraController!.stopImageStream();
        break;
      case AppLifecycleState.resumed:
        if (!cameraController!.value.isStreamingImages) {
          await cameraController!.startImageStream(onLatestImageAvailable);
        }
        break;
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    cameraController!.dispose();
    super.dispose();
  }
}
