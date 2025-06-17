import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:fit_office/src/features/authentication/controllers/login_controller.dart';
import '../../../../../constants/colors.dart';
import '../../../../../constants/sizes.dart';
import '../../../../../utils/helper/helper_controller.dart';
import 'package:fit_office/l10n/app_localizations.dart';

import '../../forget_password/forget_password_model_bottom_sheet.dart';

class LoginFormWidget extends StatelessWidget {
  const LoginFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final controller = Get.put(LoginController());
    return Container(
      padding: const EdgeInsets.only(top: 0, bottom: 0),
      child: AutofillGroup(
        child: Form(
          key: controller.loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email Field
              TextFormField(
                controller: controller.email,
                autofillHints: const [AutofillHints.username],
                validator: (value) => Helper.validateEmail(value, context),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? tDarkColor.withValues(alpha: 0.7) : Colors.grey[100],
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? tWhiteColor : tBlackColor, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  prefixIcon: Icon(LineAwesomeIcons.user, color: tPrimaryColor),
                  hintText: AppLocalizations.of(context)!.tEmail,
                  errorStyle:
                  const TextStyle(overflow: TextOverflow.visible),
                  errorMaxLines: 3,
                  label: RichText(
                    text: TextSpan(
                      text: AppLocalizations.of(context)!.tEmail,
                      style: TextStyle(color: isDark ? tWhiteColor : tBlackColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: tFormHeight - 20),
              // Password Field
              Obx(() => TextFormField(
                controller: controller.password,
                autofillHints: const [AutofillHints.password],
                validator: (value) =>
                value!.isEmpty ? 'Enter your password' : null,
                obscureText: !controller.showPassword.value,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? tDarkColor.withValues(alpha: 0.7) : Colors.grey[100],
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? tWhiteColor : tBlackColor, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  prefixIcon: const Icon(Icons.fingerprint, color: tPrimaryColor),
                  label: RichText(
                    text: TextSpan(
                      text: AppLocalizations.of(context)!.tPassword,
                      style: TextStyle(color: isDark ? tWhiteColor : tBlackColor),
                    ),
                  ),
                  hintText: AppLocalizations.of(context)!.tPassword,
                  suffixIcon: IconButton(
                    icon: controller.showPassword.value
                        ? const Icon(LineAwesomeIcons.eye)
                        : const Icon(LineAwesomeIcons.eye_slash),
                    onPressed: () => controller.showPassword.value =
                    !controller.showPassword.value,
                  ),
                ),
              )),
              const SizedBox(height: tFormHeight - 20),
              // Forget password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => ForgetPasswordScreen.buildShowModalBottomSheet(
                      context,
                      email: controller.email.text,
                      enableEdit: true),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(right: 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(AppLocalizations.of(context)!.tForgotPassword,
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                      )),
                ),
              ),
              // Login Button
              Obx(() => GestureDetector(
                onTap: controller.isLoading.value ? null : () => controller.login(context),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: tPrimaryColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: tPrimaryColor,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: tPrimaryColor, strokeWidth: 2),
                          )
                        : Text(
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
              )),
            ],
          ),
        ),
      ),
    );
  }
}
