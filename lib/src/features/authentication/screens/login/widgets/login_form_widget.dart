import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:fit_office/src/common_widgets/buttons/primary_button.dart';
import 'package:fit_office/src/features/authentication/controllers/login_controller.dart';
import '../../../../../constants/colors.dart';
import '../../../../../constants/sizes.dart';
import '../../../../../constants/text_strings.dart';
import '../../../../../utils/helper/helper_controller.dart';
import '../../forget_password/forget_password_options/forget_password_model_bottom_sheet.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginFormWidget extends StatelessWidget {
  const LoginFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final controller = Get.put(LoginController());
    return Container(
      padding: const EdgeInsets.only(top: tFormHeight - 15, bottom: 10),
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
                validator: Helper.validateEmail,
                decoration: InputDecoration(
                  prefixIcon: Icon(LineAwesomeIcons.user),
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
                  prefixIcon: const Icon(Icons.fingerprint),
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
              Obx(() => TPrimaryButton(
                isLoading: controller.isLoading.value,
                text: AppLocalizations.of(context)!.tLogin.tr,
                onPressed: controller.isLoading.value
                    ? () {}
                    : () => controller.login(),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
