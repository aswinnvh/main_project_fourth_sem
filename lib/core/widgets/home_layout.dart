import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../features/image_detector/presentation/pages/upload_image_screen.dart';
import '../../home.dart';
import '/core/util/themes.dart';
import '/features/realtime_object_detection/presentation/pages/realtime_object_detection_page.dart';

// ignore: must_be_immutable
class HomeLayout extends StatefulWidget {
  static const String routeName = 'HomePage';

  const HomeLayout({Key? key}) : super(key: key);

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  late double height;
  int selectedIndex = 0;
  late double width;
  late Widget body = HomePage(title: 'Image Labeler', onImage: (InputImage inputImage) {  },);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(builder: (context, BoxConstraints constraints) {
        height = constraints.maxHeight;
        width = constraints.maxWidth;
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: SizedBox(
            height: height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: height * 0.07,
                  child: AppBar(
                    title: const Text("HOME"),
                    backgroundColor: Colors.blueAccent.shade100,
                  ),
                ),
                SizedBox(
                  height: 0.85 * height,
                  child: body,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  width: width,
                  height: height * 0.08,
                  color: aiDarkPurple,
                  child: GNav(
                    onTabChange: (index) {
                      setState(() {
                        body = (index == 0 && selectedIndex != index)
                            ? HomePage(title: 'Image Labeler', onImage: (InputImage inputImage) {  },)
                            : (index == 1 && selectedIndex != index)
                            ? ImageLabelView()
                            : (index == 2 && selectedIndex != index)
                            ? RealTimeObjectDetectionPage()
                            // : (index == 3 && selectedIndex != index)
                            // ? const RealTimeObjectDetectionPage()
                            : Container();
                        selectedIndex = index;
                      });
                    },
                    backgroundColor: aiLightPurple,
                    haptic: false,
                    curve: Curves.easeInOutQuart,
                    gap: 8,
                    activeColor: Colors.blue,
                    iconSize: 27,
                    tabBackgroundColor: aiPurple.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    tabs: const [
                      GButton(
                        icon: Icons.home_rounded,
                        text: '  Home',
                      ),
                      // GButton(
                      //   icon: Icons.text_fields_outlined,
                      //   text: '  Text',
                      // ),
                      GButton(
                        icon: Icons.image_search_outlined,
                        text: '  Image',
                      ),
                      GButton(
                        icon: Icons.video_camera_back_rounded,
                        text: '  Object',
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
