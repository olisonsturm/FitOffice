import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/common_widgets/form/form_header_widget.dart';
import 'package:fit_office/src/constants/image_strings.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/authentication/screens/signup/signup_screen.dart';
import '../../../../common_widgets/buttons/clickable_richtext_widget.dart';
import '../../../../common_widgets/form/form_divider_widget.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/sizes.dart';
import 'widgets/login_form_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {

    var mediaQuery = MediaQuery.of(context);
    var width = mediaQuery.size.width;
    var height = mediaQuery.size.height;
    var brightness = mediaQuery.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDarkMode ? tSecondaryColor : tWhiteColor,
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(tDefaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormHeaderWidget(
                    image: tWelcomeScreenImage,
                    title: tLoginTitle,
                    subTitle: tLoginSubTitle,
                    imageHeight: 0.2,
                    heightBetween: tFormHeight * 2,
                ),
                //const SizedBox(height: tDefaultSpace * 2),
                const LoginFormWidget(),
                ClickableRichTextWidget(
                  text1: tDontHaveAnAccount,
                  text2: tSignup,
                  onPressed: () => Get.off(() => const SignupScreen()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
