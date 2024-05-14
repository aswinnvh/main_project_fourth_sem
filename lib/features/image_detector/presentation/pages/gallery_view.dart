import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image_picker/image_picker.dart';

import 'utils.dart';

class GalleryView extends StatefulWidget {
  const GalleryView(
      {Key? key,
        required this.title,
        this.text,
        required this.onImage,
        required this.onDetectorViewModeChanged})
      : super(key: key);

  final String title;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function()? onDetectorViewModeChanged;

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  File? _image;
  String? _path;
  ImagePicker? _imagePicker;

  @override
  void initState() {
    super.initState();

    _imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: widget.onDetectorViewModeChanged,
                child: Icon(
                  Platform.isIOS ? Icons.camera_alt_outlined : Icons.camera,
                ),
              ),
            ),
          ],
        ),
        body: _galleryBody());
  }

  Widget _galleryBody() {
    return ListView(shrinkWrap: true, children: [
      _image != null
          ? SizedBox(
        height: 400,
        width: 400,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.file(_image!),
          ],
        ),
      )
          : const Icon(
        Icons.image,
        size: 260,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          onPressed: _getImageAsset,
          child: const Text('From Assets'),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: const Text('From Gallery'),
          onPressed: () => _getImage(ImageSource.gallery),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: const Text('Take a picture'),
          onPressed: () => _getImage(ImageSource.camera),
        ),
      ),
      if (_image != null)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
              '${_path == null ? '' : 'Image path: $_path'}\n\n${widget.text ?? ''}'),
        ),
    ]);
  }

  Future _getImage(ImageSource source) async {
    setState(() {
      _image = null;
      _path = null;
    });
    final pickedFile = await _imagePicker?.pickImage(source: source);
    if (pickedFile != null) {
      _processFile(pickedFile.path);
    }
  }

  Future _getImageAsset() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final assets = manifestMap.keys
        .where((String key) => key.contains('images/'))
        .where((String key) =>
    key.contains('.jpg') ||
        key.contains('.jpeg') ||
        key.contains('.png') ||
        key.contains('.webp'))
        .toList();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select image',
                    style: TextStyle(fontSize: 20),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.7),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (final path in assets)
                            GestureDetector(
                              onTap: () async {
                                Navigator.of(context).pop();
                                _processFile(await getAssetPath(path));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(path),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel')),
                ],
              ),
            ),
          );
        });
  }

  Future _processFile(String path) async {
    setState(() {
      _image = File(path);
    });
    _path = path;
    final inputImage = InputImage.fromFilePath(path);
    widget.onImage(inputImage);
  }
}



//
// Here's a breakdown of the code for the GalleryView widget in Flutter:
//
// 1. Widget and State:
//
// GalleryView: This widget provides a visual interface for selecting images from various sources for object detection.
// _GalleryViewState: This is the state class managing the widget's internal data and behavior.
// 2. Properties:
//
// title: The title displayed in the app bar.
// text: Optional text to display below the image (e.g., instructions).
// onImage: A callback function that receives an InputImage object for processing when a valid image is selected.
// onDetectorViewModeChanged: A callback function to switch back to the live camera view.
// _image: The selected image file (if any).
// _path: The path to the selected image.
// _imagePicker: An instance of the ImagePicker plugin for accessing the image gallery and camera.
// 3. Build Method:
//
// Constructs the UI:
// App bar with title and a back button to switch to live camera mode.
// Image display area for the selected image (placeholder icon if none).
// Buttons for choosing images from various sources:
// "From Assets": Selects an image from the app's asset bundle.
// "From Gallery": Picks an image from the device's photo gallery.
// "Take a picture": Captures a new image using the camera.
// Optional text display for image path and additional information.
// 4. Image Selection Methods:
//
// _getImage(ImageSource): Handles image selection from gallery or camera:
// Clears the previous image selection.
// Uses _imagePicker to prompt the user to pick an image.
// If a valid image is selected, calls _processFile to handle it.
// _getImageAsset(): Selects an image from the asset bundle:
// Loads AssetManifest.json to list available image assets.
// Displays a dialog with scrollable thumbnails of those images.
// Upon image selection, calls _processFile for the selected asset path.
// 5. Image Processing:
//
// _processFile(String path): Processes a selected image:
// Updates UI state with the image file and path.
// Creates an InputImage object from the file path.
// Calls the onImage callback function to pass the InputImage for further processing (e.g., object detection).