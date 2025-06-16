import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/features/authentication/screens/signup/signup_screen.dart';
import '../../../../constants/colors.dart';
import '../../../../constants/image_strings.dart';
import '../../../../utils/animations/fade_in_animation/animation_design.dart';
import '../../../../utils/animations/fade_in_animation/fade_in_animation_controller.dart';
import '../../../../utils/animations/fade_in_animation/fade_in_animation_model.dart';
import '../login/login_screen.dart';
import 'package:fit_office/l10n/app_localizations.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FadeInAnimationController());
    controller.animationIn();

    var mediaQuery = MediaQuery.of(context);
    var width = mediaQuery.size.width;
    var brightness = mediaQuery.platformBrightness;
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? tDarkColor : tWhiteColor,
      body: Stack(
        children: [
          // Main content (logo, title, subtitle)
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(flex: 2), // Push content to about halfway down
                Hero(
                  tag: 'welcome-image-tag',
                  child: Image(
                    image: const AssetImage(tLogoImage),
                    width: width * 0.7,
                    height: width * 0.7,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.tWelcomeTitle,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: isDark ? tWhiteColor : tBlackColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    AppLocalizations.of(context)!.tWelcomeSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color: isDark
                          ? tWhiteColor.withValues(alpha: 0.7)
                          : tBlackColor.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Spacer(flex: 3), // Fill remaining space below
              ],
            ),
          ),
          // Buttons and copyright (animated, at the bottom)
          TFadeInAnimation(
            isTwoWayAnimation: false,
            durationInMs: 1400,
            animate: TAnimatePosition(
              bottomAfter: 0,
              bottomBefore: -50,
              leftBefore: 0,
              leftAfter: 0,
              topAfter: null,
              topBefore: null,
              rightAfter: 0,
              rightBefore: 0,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Login button
                    GestureDetector(
                      onTap: () => Get.to(() => const LoginScreen()),
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: tPrimaryColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: tPrimaryColor,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.tLogin.toUpperCase(),
                            style: TextStyle(
                              color: isDark ? tBlackColor : tWhiteColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Signup button
                    GestureDetector(
                      onTap: () => Get.to(() => const SignupScreen()),
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.tSignup.toUpperCase(),
                            style: TextStyle(
                              color: isDark ? tWhiteColor : tBlackColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Copyright
                    Text(
                      '© 2025 DHBW Ravensburg',
                      style: TextStyle(
                        color: isDark
                            ? tWhiteColor.withValues(alpha: 0.5)
                            : tBlackColor.withValues(alpha: 0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}