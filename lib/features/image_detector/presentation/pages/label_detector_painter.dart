import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class LabelDetectorPainter extends CustomPainter {
  LabelDetectorPainter(this.labels);

  final List<ImageLabel> labels;

  @override
  void paint(Canvas canvas, Size size) {
    final ui.ParagraphBuilder builder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
          textAlign: TextAlign.left,
          fontSize: 23,
          textDirection: TextDirection.ltr),
    );

    builder.pushStyle(ui.TextStyle(color: Colors.blue));
    for (final ImageLabel label in labels) {
      builder.addText('Label: ${label.label}, '
          'Confidence: ${label.confidence.toStringAsFixed(2)}\n');
    }
    builder.pop();

    canvas.drawParagraph(
      builder.build()
        ..layout(ui.ParagraphConstraints(
          width: size.width,
        )),
      const Offset(0, 0),
    );
  }

  @override
  bool shouldRepaint(LabelDetectorPainter oldDelegate) {
    return oldDelegate.labels != labels;
  }
}

// This code defines a custom painter widget called LabelDetectorPainter in Flutter for visualizing image classification labels. Here's a breakdown of its functionalities:
//
// Properties:
//
// labels: A list of ImageLabel objects representing the detected labels in an image.
// Methods:
//
// paint(Canvas canvas, Size size): This is the core method where the painter draws on the canvas:
// Creates a ui.ParagraphBuilder object to build styled text.
// Sets text style properties (alignment, font size, direction).
// Iterates through the labels list and adds formatted text for each label (including its confidence score).
// Draws the built paragraph on the canvas at the top-left corner (0, 0).
// shouldRepaint(LabelDetectorPainter oldDelegate): This method determines when to repaint the widget:
// Returns true if the labels list is different from the previous painter's labels. This ensures the painter updates when new labels are available.
// Overall, this LabelDetectorPainter helps visualize the results of image classification by drawing detected labels and their confidence scores as formatted text on top of the image.