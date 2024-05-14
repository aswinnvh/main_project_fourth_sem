import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'features/image_detector/presentation/pages/detector_view.dart';
import 'features/image_detector/presentation/pages/upload_image_screen.dart';
import 'features/realtime_object_detection/presentation/pages/realtime_object_detection_page.dart';

class HomePage extends StatefulWidget {
  final String title;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function(DetectorViewMode mode)? onDetectorViewModeChanged;
  final DetectorViewMode initialDetectionMode;

  const HomePage({
    Key? key,
    required this.title,
    required this.onImage,
    this.text,
    this.onDetectorViewModeChanged,
    this.initialDetectionMode = DetectorViewMode.liveFeed,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late DetectorViewMode _mode;

  @override
  void initState() {
    _mode = widget.initialDetectionMode;
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          actions: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.notification_add_outlined),
            )
          ],
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Object Detection",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CarouselSlider(
                items: [
                  Container(
                    child: Center(child: Image.asset("assets/images/home3.jpg")),
                  ),

                  Container(
                    child: Center(child: Image.asset('assets/images/home1.jpg')),
                  ),
                  Container(
                    child: Center(
                        child: Image.asset(
                          'assets/images/home2.jpg',
                          fit: BoxFit.contain,
                        )),
                  ),
                ],
                options: CarouselOptions(
                  height: 300,
                  aspectRatio: 16 / 9,
                  viewportFraction: 1.0,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  "Click below to get image or object detection results",
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  children: [
                    _buildGridItem(
                     // icon: Icons.image,
                      label: 'Image Detection',
                      imagePath: 'assets/images/home5.jpg',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ImageLabelView()));
                      },
                    ),
                    _buildGridItem(
                     // icon: Icons.camera,
                      label: 'Real-time Object Detection',
                      imagePath: 'assets/images/home4.jpg',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    RealTimeObjectDetectionPage()));
                      },
                    ),
                  ],
                ),
              ),

            ],

          ),
        ),
      ),
    );
  }

  Widget _buildGridItem({
   // required IconData icon,
    required String label,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
        //  mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 100.0,
              height: 100.0,
            ),
            // Icon(
            //   icon,
            //   size: 50.0,
            //   color: Colors.blue,
            // ),
            const SizedBox(height: 6.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
