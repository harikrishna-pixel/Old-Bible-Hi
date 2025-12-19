import 'package:biblebookapp/view/constants/colors.dart';
import 'package:biblebookapp/view/screens/dashboard/constants.dart';
import 'package:biblebookapp/view/screens/dashboard/preference_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final List<String> boardingImages = [
    'assets/onboarding/1.jpg',
    'assets/onboarding/2.jpg',
    'assets/onboarding/3.jpg',
    'assets/onboarding/4.jpg',
    'assets/onboarding/5.jpg',
  ];

  late PageController pageController;
  late int currentIndex;

  pageListener() {
    currentIndex = pageController.page?.toInt() ?? 0;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
    pageController = PageController();
    pageController.addListener(pageListener);
  }

  endNavigation() async {
    //  Get.offAll(() => SignupScreen());
    Get.offAll(() => PreferenceSelectionScreen(
          isSetting: false,
        ));
  }

  // Future<void> requestTrackingPermission() async {
  //   final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  //   if (status == TrackingStatus.notDetermined) {
  //     await AppTrackingTransparency.requestTrackingAuthorization();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    double screenWidth = MediaQuery.of(context).size.width;
    debugPrint("sz current width - $screenWidth ");
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            PageView.builder(
              controller: pageController,
              itemBuilder: (context, index) => Image.asset(
                boardingImages[index],
                fit: BoxFit.cover,
              ),
              itemCount: boardingImages.length,
            ),
            Positioned(
              right: 20,
              top: MediaQuery.of(context).viewPadding.top + 20,
              child: GestureDetector(
                onTap: () {
                  endNavigation();
                },
                child: Text("Skip",
                    style: screenWidth > 450
                        ? CommanStyle.bw14400(context).copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black,
                            fontSize: BibleInfo.fontSizeScale * 25,
                            color: Colors.black)
                        : CommanStyle.bw14400(context).copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black,
                            color: Colors.black)),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              child: SmoothPageIndicator(
                controller: pageController,
                count: boardingImages.length,
                effect: const WormEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    strokeWidth: 3,
                    activeDotColor: CommanColor.darkPrimaryColor),
              ),
            ),
            Positioned(
              bottom: 40,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  if (currentIndex + 1 < boardingImages.length) {
                    pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeIn);
                  } else {
                    endNavigation();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: CommanColor.darkPrimaryColor,
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_right,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
