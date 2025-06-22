import 'package:fit_office/src/features/authentication/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/image_strings.dart';
import 'package:fit_office/src/features/authentication/screens/signup/widgets/signup_form_widget.dart';
import 'package:get/get.dart';
import '../../../../constants/colors.dart';
import 'package:fit_office/l10n/app_localizations.dart';

/// SignupScreen widget that displays a signup form with a logo, title, subtitle, and navigation to login.
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: isDark ? tBlackColor : tWhiteColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: width * 0.92,
            constraints: BoxConstraints(
              minHeight: height * 0.92,
              maxWidth: 420,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Hero(
                  tag: 'welcome-image-tag',
                  child: Image(
                    image: const AssetImage(tLogoImage),
                    width: width * 0.5,
                    height: width * 0.5,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  AppLocalizations.of(context)!.tSignUpTitle,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        color: isDark ? tWhiteColor : tBlackColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    AppLocalizations.of(context)!.tSignUpSubTitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: isDark
                              ? tWhiteColor.withValues(alpha: 0.7)
                              : tBlackColor.withValues(alpha: 0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                // Signup form in a card
                Card(
                  color: isDark ? tDarkColor : Colors.white,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                    child: Column(
                      children: const [
                        SignUpFormWidget(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Login navigation styled as button
                GestureDetector(
                  onTap: () => Get.off(() => const LoginScreen()),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
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
                        AppLocalizations.of(context)!.tLogin.toUpperCase(),
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
                const SizedBox(height: 16),
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
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
