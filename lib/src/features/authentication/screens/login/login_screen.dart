import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/common_widgets/form/form_header_widget.dart';
import 'package:fit_office/src/common_widgets/form/social_footer.dart';
import 'package:fit_office/src/constants/image_strings.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/authentication/screens/signup/signup_screen.dart';
import '../../../../common_widgets/form/form_divider_widget.dart';
import '../../../../constants/sizes.dart';
import 'widgets/login_form_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(tDefaultSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormHeaderWidget(image: tWelcomeScreenImage, title: tLoginTitle, subTitle: tLoginSubTitle),
                const LoginFormWidget(),
                const TFormDividerWidget(),
                SocialFooter(text1: tDontHaveAnAccount, text2: tSignup, onPressed: () => Get.off(() => const SignupScreen())),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
