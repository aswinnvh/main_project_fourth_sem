import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

import 'camera_view.dart';
import 'gallery_view.dart';

enum DetectorViewMode { liveFeed, gallery }

class DetectorView extends StatefulWidget {
  DetectorView({
    Key? key,
    required this.title,
    required this.onImage,
    this.customPaint,
    this.text,
    this.initialDetectionMode = DetectorViewMode.liveFeed,
    this.initialCameraLensDirection = CameraLensDirection.back,
    this.onCameraFeedReady,
    this.onDetectorViewModeChanged,
    this.onCameraLensDirectionChanged,
  }) : super(key: key);

  final String title;
  final CustomPaint? customPaint;
  final String? text;
  final DetectorViewMode initialDetectionMode;
  final Function(InputImage inputImage) onImage;
  final Function()? onCameraFeedReady;
  final Function(DetectorViewMode mode)? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  @override
  State<DetectorView> createState() => _DetectorViewState();
}

class _DetectorViewState extends State<DetectorView> {
  late DetectorViewMode _mode;

  @override
  void initState() {
    _mode = widget.initialDetectionMode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _mode == DetectorViewMode.liveFeed
        ? CameraView(
      customPaint: widget.customPaint,
      onImage: widget.onImage,
      onCameraFeedReady: widget.onCameraFeedReady,
      onDetectorViewModeChanged: _onDetectorViewModeChanged,
      initialCameraLensDirection: widget.initialCameraLensDirection,
      onCameraLensDirectionChanged: widget.onCameraLensDirectionChanged,
    )
        : GalleryView(
        title: widget.title,
        text: widget.text,
        onImage: widget.onImage,
        onDetectorViewModeChanged: _onDetectorViewModeChanged);
  }

  void _onDetectorViewModeChanged() {
    if (_mode == DetectorViewMode.liveFeed) {
      _mode = DetectorViewMode.gallery;
    } else {
      _mode = DetectorViewMode.liveFeed;
    }
    if (widget.onDetectorViewModeChanged != null) {
      widget.onDetectorViewModeChanged!(_mode);
    }
    setState(() {});
  }
}



// Absolutely, this code defines a DetectorView widget that acts as a container for switching between live camera feed and image gallery for object detection in Flutter. Here's a breakdown of its functionalities:
//
// Class:
//
// DetectorView: This widget manages the view mode (live camera or gallery) for object detection and provides callbacks for processing images.
// Constructor:
//
// DetectorView({...}): This constructor takes various arguments:
// title: The title displayed on the screen.
// customPaint: A custom paint widget to be drawn on top of the camera preview (for live mode).
// text: Optional text to display (potentially instructions for the gallery mode).
// initialDetectionMode: Specifies the initial view mode (default is live feed).
// initialCameraLensDirection: Specifies the initial camera lens direction (default is back, relevant for live mode).
// onImage: A callback function to receive images (from camera or gallery) as InputImage objects for processing.
// onCameraFeedReady: A callback function called when the camera feed is ready (relevant for live mode).
// onDetectorViewModeChanged: A callback function called when the view mode is switched between live and gallery.
// onCameraLensDirectionChanged: A callback function called when the camera lens is switched (front/back, relevant for live mode).
// State:
//
// _mode: This variable stores the current view mode (DetectorViewMode.liveFeed or DetectorViewMode.gallery).
// Methods:
//
// initState: Initializes the state and sets the initial view mode based on the constructor argument.
// build: Builds the widget tree based on the current view mode:
// If _mode is DetectorViewMode.liveFeed:
// Displays a CameraView widget with provided callbacks and configuration.
// If _mode is DetectorViewMode.gallery:
// Displays a GalleryView widget with provided title, text, and callbacks.
// _onDetectorViewModeChanged: Handles switching between live and gallery modes:
// Updates the _mode state.
// Calls the onDetectorViewModeChanged callback if provided.
// Rebuilds the widget to reflect the change.
// Overall, this DetectorView widget provides a flexible way to switch between live camera feed and image gallery for object detection in your Flutter application. It manages the underlying CameraView and GalleryView widgets based on the current mode and handles callbacks for processing captured images.