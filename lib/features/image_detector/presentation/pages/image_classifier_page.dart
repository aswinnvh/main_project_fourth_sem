import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '/core/util/themes.dart';
import '/features/image_detector/presentation/bloc/image_detector_bloc.dart';
import '/features/image_detector/presentation/bloc/image_detector_events.dart';
import '/features/image_detector/presentation/bloc/image_detector_states.dart';
import '/core/services/service_locator.dart';
import '../widgets/image_result_widget.dart';
import '../widgets/image_show_widget.dart';

class ImageClassifierPage extends StatelessWidget {
  ImageClassifierPage({Key? key, required this.height, required this.width, this.image, this.imageWidget}) : super(key: key);

  final double height;
  final double width;
  final File? image;
  final Image? imageWidget;
  final picker = ImagePicker();

  static const String routeName = 'ImageClassifierHomePage';

  Future<void> getImage(BuildContext context) async {
    // Request permission to access storage
    PermissionStatus status = await Permission.storage.request();

    // Check if permission is granted
    if (status.isGranted) {
      // Permission is granted, proceed with picking an image
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final File pickedImage = File(pickedFile.path);
        BlocProvider.of<ImageDetectorBloc>(context)
            .add(DetectImageEvent(imagePath: pickedFile.path));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageClassifierPage(
              height: height,
              width: width,
              image: pickedImage,
              imageWidget: Image.file(pickedImage),
            ),
          ),
        );
      }
    } else if (status.isDenied) {
      print('Permission denied by user');
    } else if (status.isPermanentlyDenied) {
      print('Permission permanently denied by user');
      openAppSettings();
    }
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      final double height = constraints.maxHeight;
      final double width = constraints.maxWidth;
      return BlocProvider(
        create: (BuildContext context) => sl<ImageDetectorBloc>(),
        child: BlocBuilder<ImageDetectorBloc, ImageDetectorState>(
          builder: (context, state) {
            return Column(
              children: [
                Container(
                  height: height / 2,
                  width: width,
                  margin: const EdgeInsets.all(18.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: aiPurple.withOpacity(0.16),
                        blurRadius: 8,
                        spreadRadius: 8,
                      )
                    ],
                    color: aiPurple.withOpacity(0.8),
                  ),
                  child: state is DetectImageLoadingState
                      ? const CircularProgressIndicator()
                      : image != null
                      ? ImageShowWidget(image: image)
                      : Container(),
                ),
                state is DetectImageSuccessState
                    ? ImageResultWidget(
                  height: height,
                  width: width,
                  text: state.result,
                )
                    : Container(),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.all(18.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 32.0,
                      ),
                      onPressed: () {
                        getImage(context);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    });
  }
}

//
// Absolutely, this code defines an ImageClassifierPage widget in Flutter for a mobile application that uses a pre-trained image classification model to detect objects in user-selected images. Here's a breakdown of its functionalities:
//
// 1. Properties:
//
// height: The height of the widget.
// width: The width of the widget.
// image: The selected image file (if any).
// imageWidget: The image widget to display (if an image is selected).
// picker: An instance of the ImagePicker plugin for picking images.
// 2. Methods:
//
// getImage(BuildContext context): Requests storage permission, picks an image from the gallery if granted, and triggers image classification.
// Requests storage permission using the Permission class.
// Based on the permission status:
// If granted, picks an image using ImagePicker.
// If denied, logs a message.
// If permanently denied, logs a message and opens app settings.
// Triggers image classification by adding a DetectImageEvent to the ImageDetectorBloc (assumed to be a state management bloc).
// build(BuildContext context): Builds the UI layout:
// Uses a LayoutBuilder to adapt to different screen sizes.
// Wraps the widget tree in a BlocProvider for the ImageDetectorBloc.
// Uses a BlocBuilder to rebuild the UI based on the ImageDetectorBloc state:
// Displays a container with rounded corners and a shadow for the image area.
// Shows a progress indicator while classification is loading (DetectImageLoadingState).
// Displays the selected image using ImageShowWidget if available.
// Displays the classification result using ImageResultWidget if successful (DetectImageSuccessState).
// Positions a floating action button in the bottom right corner to pick an image.
// 3. Child Widgets:
//
// ImageShowWidget: Presumably a widget to display the selected image.
// ImageResultWidget: Presumably a widget to display the image classification result text.
// Overall, this ImageClassifierPage demonstrates how to integrate image picking, state management, and potentially widget communication for image classification tasks in a Flutter application.
//


