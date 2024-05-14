import 'package:flutter/material.dart';
import '../widgets/stats_row_widget.dart';
import '/core/util/themes.dart';

import '../../../../core/ml/realtime_object_detection_classifier/recognition.dart';
import '../../../../core/ml/realtime_object_detection_classifier/stats.dart';
import '../widgets/camera_view.dart';
import '../widgets/camera_view_singleton.dart';
import '../widgets/object_box_widget.dart';

class RealTimeObjectDetectionPage extends StatefulWidget {
  const RealTimeObjectDetectionPage({Key? key}) : super(key: key);

  static const String routeName = 'RealTimeObjectDetectionHomePage';

  @override
  State<RealTimeObjectDetectionPage> createState() =>
      _RealTimeObjectDetectionPageState();

  static const BOTTOM_SHEET_RADIUS = Radius.circular(24.0);
  static const BORDER_RADIUS_BOTTOM_SHEET = BorderRadius.only(
    topLeft: BOTTOM_SHEET_RADIUS,
    topRight: BOTTOM_SHEET_RADIUS,
  );
}

class _RealTimeObjectDetectionPageState
    extends State<RealTimeObjectDetectionPage> {
  List<Recognition>? results;
  Stats? stats;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  Map<String, int> objectCounts = {}; // Map to store object counts

  Widget boundingBoxes(List<Recognition>? results) {
    if (results == null) {
      return Container();
    }
    return Stack(
      children: results.map((e) => BoxWidget(result: e)).toList(),
    );
  }

  void resultsCallback(List<Recognition> results) {
    if (mounted) {
      setState(() {
        this.results = results;
        updateObjectCounts(results); // Update object counts
      });
    }
  }

  void updateObjectCounts(List<Recognition> results) {
    objectCounts.clear(); // Clear existing counts
    for (var recognition in results) {
      String label = recognition.label;
      if (objectCounts.containsKey(label)) {
        objectCounts[label] = objectCounts[label]! + 1; // Null-aware operator applied here
      } else {
        objectCounts[label] = 1; // Initialize count if label doesn't exist
      }
    }
  }

  void statsCallback(Stats stats) {
    if (mounted) {
      setState(() {
        this.stats = stats;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: [
          CameraView(resultsCallback, statsCallback),
          boundingBoxes(results),
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.1,
              maxChildSize: 0.5,
              builder: (_, ScrollController scrollController) => Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: aiDarkPurple.withOpacity(0.9),
                  borderRadius:
                  RealTimeObjectDetectionPage.BORDER_RADIUS_BOTTOM_SHEET,
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.keyboard_arrow_up,
                          size: 48,
                          color: aiPurple,
                        ),
                        (stats != null)
                            ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              StatsRow(
                                'Inference time:',
                                '${stats!.inferenceTime} ms',
                              ),
                              StatsRow(
                                'Total prediction time:',
                                '${stats!.totalElapsedTime} ms',
                              ),
                              StatsRow(
                                'Pre-processing time:',
                                '${stats!.preProcessingTime} ms',
                              ),
                              StatsRow(
                                'Frame',
                                '${CameraViewSingleton.inputImageSize?.width} X ${CameraViewSingleton.inputImageSize?.height}',
                              ),
                              const SizedBox(height: 16),
                              // Display object counts
                              const Text(
                                'Object Counts:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Column(
                                children: objectCounts.entries
                                    .map((entry) => Padding(
                                  padding:
                                  const EdgeInsets.symmetric(
                                      vertical: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '${entry.value}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                                    .toList(),
                              ),
                            ],
                          ),
                        )
                            : Container()
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
