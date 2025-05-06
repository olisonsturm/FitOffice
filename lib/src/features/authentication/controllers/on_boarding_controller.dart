import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
  import 'package:get_storage/get_storage.dart';
  import 'package:liquid_swipe/PageHelpers/LiquidController.dart';
  import 'package:fit_office/src/features/authentication/screens/welcome/welcome_screen.dart';
  import '../../../constants/colors.dart';
  import '../../../constants/image_strings.dart';
  import '../../../constants/text_strings.dart';
  import '../models/model_on_boarding.dart';
  import '../screens/on_boarding/on_boarding_page_widget.dart';

  class OnBoardingController extends GetxController {
    // Variables
    final userStorage = GetStorage(); // Use for local Storage
    final controller = LiquidController();
    RxInt currentPage = 0.obs;

    // Functions to trigger Skip, Next and onPageChange Events
    dynamic skip() => controller.jumpToPage(page: 2);

    dynamic animateToNextSlide() => controller.animateToPage(page: controller.currentPage + 1);

    void animateToNextSlideWithLocalStorage() {
      if (controller.currentPage == 2) {
        userStorage.write('isFirstTime', false);
        if (kDebugMode) {
          print(userStorage.read('isFirstTime'));
        }
        Get.offAll(() => const WelcomeScreen());
      } else {
        controller.animateToPage(page: controller.currentPage + 1);
      }
    }

    void onPageChangedCallback(int activePageIndex) {
      if (activePageIndex == 3) {
        // If the user swipes past the last page, redirect to WelcomeScreen
        userStorage.write('isFirstTime', false);
        Get.offAll(() => const WelcomeScreen());
      } else {
        currentPage.value = activePageIndex;
      }
    }

    // Three Onboarding Pages
    final pages = [
      OnBoardingPageWidget(
        model: OnBoardingModel(
          image: tOnBoardingImage1,
          title: tOnBoardingTitle1,
          subTitle: tOnBoardingSubTitle1,
          counterText: tOnBoardingCounter1,
          bgColor: tOnBoardingPage1Color,
        ),
      ),
      OnBoardingPageWidget(
        model: OnBoardingModel(
          image: tOnBoardingImage2,
          title: tOnBoardingTitle2,
          subTitle: tOnBoardingSubTitle2,
          counterText: tOnBoardingCounter2,
          bgColor: tOnBoardingPage2Color,
        ),
      ),
      OnBoardingPageWidget(
        model: OnBoardingModel(
          image: tOnBoardingImage3,
          title: tOnBoardingTitle3,
          subTitle: tOnBoardingSubTitle3,
          counterText: tOnBoardingCounter3,
          bgColor: tOnBoardingPage3Color,
        ),
      ),
      Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(
            color: tPrimaryColor,
            strokeWidth: 2.0,
          ),
        ),
      )
    ];
  }