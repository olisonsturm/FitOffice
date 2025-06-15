import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:fit_office/src/utils/helper/helper_controller.dart';
import 'package:fit_office/l10n/app_localizations.dart';
import '../../../../../constants/colors.dart';
import '../../../../../constants/sizes.dart';
import '../../../controllers/signup_controller.dart';

//TODO: If the document of the user already exists, the user account will be still created.
class SignUpFormWidget extends StatelessWidget {
  const SignUpFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final controller = Get.put(SignUpController());
    return Container(
      padding: const EdgeInsets.only(top: 0, bottom: 0),
      child: AutofillGroup(
        child: Form(
          key: controller.signupFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username
              TextFormField(
                controller: controller.userName,
                autofillHints: const [AutofillHints.username],
                validator: (value) => Helper.validateUsername(value, context),
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
                  errorStyle: const TextStyle(overflow: TextOverflow.visible),
                  errorMaxLines: 3,
                  label: RichText(
                    text: TextSpan(
                      text: AppLocalizations.of(context)!.tUserName,
                      style: TextStyle(color: isDark ? tWhiteColor : tBlackColor),
                      children: const [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  prefixIcon: const Icon(LineAwesomeIcons.user, color: tPrimaryColor,),
                ),
              ),
              const SizedBox(height: tFormHeight - 20),

              // Full Name
              TextFormField(
                controller: controller.fullName,
                autofillHints: const [AutofillHints.name],
                validator: (value) => Helper.validateFullName(value, context),
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
                  errorStyle: const TextStyle(overflow: TextOverflow.visible),
                  errorMaxLines: 3,
                  label: RichText(
                    text: TextSpan(
                      text: AppLocalizations.of(context)!.tFullName,
                      style: TextStyle(color: isDark ? tWhiteColor : tBlackColor)
                    ),
                  ),
                  prefixIcon: const Icon(LineAwesomeIcons.user_tag_solid, color: tPrimaryColor,),
                ),
              ),
              const SizedBox(height: tFormHeight - 20),

              // Email
              TextFormField(
                controller: controller.email,
                autofillHints: const [AutofillHints.email],
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
                  errorStyle: const TextStyle(overflow: TextOverflow.visible),
                  errorMaxLines: 3,
                  label: RichText(
                    text: TextSpan(
                      text: AppLocalizations.of(context)!.tEmail,
                      style: TextStyle(color: isDark ? tWhiteColor : tBlackColor),
                      children: const [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  prefixIcon: const Icon(LineAwesomeIcons.envelope, color: tPrimaryColor,),
                ),
              ),
              const SizedBox(height: tFormHeight - 20),

              // Password
              Obx(() => TextFormField(
                controller: controller.password,
                autofillHints: const [AutofillHints.newPassword],
                validator: (value) => Helper.validatePassword(value, context),
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
                  errorStyle:
                  const TextStyle(overflow: TextOverflow.visible),
                  errorMaxLines: 3,
                  label: RichText(
                    text: TextSpan(
                      text: AppLocalizations.of(context)!.tPassword,
                      style: TextStyle(color: isDark ? tWhiteColor : tBlackColor),
                      children: const [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  prefixIcon: const Icon(Icons.fingerprint, color: tPrimaryColor,),
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

              // Confirm Password
              Obx(() => TextFormField(
                controller: controller.confirmPassword,
                autofillHints: const [AutofillHints.newPassword],
                obscureText: !controller.showPassword.value,
                validator: (value) =>
                    Helper.repeatPassword(value!, controller, context),
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
                  errorStyle:
                  const TextStyle(overflow: TextOverflow.visible),
                  errorMaxLines: 3,
                  label: RichText(
                    text: TextSpan(
                      text: 'Confirm Password',
                      style: TextStyle(color: isDark ? tWhiteColor : tBlackColor),
                      children: const [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  prefixIcon: const Icon(Icons.fingerprint, color: tPrimaryColor,),
                  suffixIcon: IconButton(
                    icon: controller.showPassword.value
                        ? const Icon(LineAwesomeIcons.eye)
                        : const Icon(LineAwesomeIcons.eye_slash),
                    onPressed: () => controller.showPassword.value =
                    !controller.showPassword.value,
                  ),
                ),
              )),
              const SizedBox(height: tFormHeight - 10),

              // Submit Button
              Obx(() => GestureDetector(
                onTap: controller.isLoading.value ? null : () async {
                  final localizations = AppLocalizations.of(context)!;
                  if (controller.signupFormKey.currentState!.validate()) {
                    bool usernameExists = await Helper.isUsernameTaken(
                        controller.userName.text);
                    if (usernameExists) {
                      Helper.errorSnackBar(
                          title: 'Error',
                          message: localizations.tUserNameAlreadyExists);
                    } else {
                      controller.createUser();
                    }
                  }
                },
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
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            AppLocalizations.of(context)!.tSignup.toUpperCase(),
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
