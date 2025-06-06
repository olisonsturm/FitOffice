import 'package:fit_office/src/features/authentication/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/image_strings.dart';
import 'package:fit_office/src/constants/text_strings.dart';
import 'package:fit_office/src/features/authentication/screens/signup/widgets/signup_form_widget.dart';
import 'package:get/get.dart';
import '../../../../common_widgets/buttons/clickable_richtext_widget.dart';
import '../../../../common_widgets/form/form_header_widget.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/sizes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? tBlackColor : tWhiteColor,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(tDefaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormHeaderWidget(
                  image: tWelcomeScreenImage,
                  heightBetween: tFormHeight * 2,
                  title: AppLocalizations.of(context)!.tSignUpTitle,
                  subTitle: AppLocalizations.of(context)!.tSignUpSubTitle,
                  imageHeight: 0.2
              ),
              const SignUpFormWidget(),
              ClickableRichTextWidget(
                text1: AppLocalizations.of(context)!.tAlreadyHaveAnAccount,
                text2: AppLocalizations.of(context)!.tLogin,
                onPressed: () => Get.off(() => const LoginScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
