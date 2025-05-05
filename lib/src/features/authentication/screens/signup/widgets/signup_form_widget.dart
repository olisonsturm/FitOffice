import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:fit_office/src/utils/helper/helper_controller.dart';
import '../../../../../common_widgets/buttons/primary_button.dart';
import '../../../../../constants/sizes.dart';
import '../../../../../constants/text_strings.dart';
import '../../../controllers/signup_controller.dart';

//TODO: If the document of the user already exists, the user account will be still created.
class SignUpFormWidget extends StatelessWidget {
  const SignUpFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignUpController());
    return Container(
      padding: const EdgeInsets.only(top: tFormHeight - 15, bottom: 10),
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
                validator: Helper.validateUsername,
                decoration: InputDecoration(
                  errorStyle: const TextStyle(overflow: TextOverflow.visible),
                  errorMaxLines: 3,
                  label: RichText(
                    text: const TextSpan(
                      text: tUserName,
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  prefixIcon: const Icon(LineAwesomeIcons.user),
                ),
              ),
              const SizedBox(height: tFormHeight - 20),

              // Full Name
              TextFormField(
                controller: controller.fullName,
                autofillHints: const [AutofillHints.name],
                validator: Helper.validateFullName,
                decoration: const InputDecoration(
                  errorStyle: TextStyle(overflow: TextOverflow.visible),
                  errorMaxLines: 3,
                  label: Text(tFullName),
                  prefixIcon: Icon(LineAwesomeIcons.user_tag_solid),
                ),
              ),
              const SizedBox(height: tFormHeight - 20),

              // Email
              TextFormField(
                controller: controller.email,
                autofillHints: const [AutofillHints.email],
                validator: Helper.validateEmail,
                decoration: InputDecoration(
                  errorStyle: const TextStyle(overflow: TextOverflow.visible),
                  errorMaxLines: 3,
                  label: RichText(
                    text: const TextSpan(
                      text: tEmail,
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  prefixIcon: const Icon(LineAwesomeIcons.envelope),
                ),
              ),
              const SizedBox(height: tFormHeight - 20),

              // Password
              Obx(() => TextFormField(
                controller: controller.password,
                autofillHints: const [AutofillHints.newPassword],
                validator: Helper.validatePassword,
                obscureText: !controller.showPassword.value,
                decoration: InputDecoration(
                  errorStyle:
                  const TextStyle(overflow: TextOverflow.visible),
                  errorMaxLines: 3,
                  label: RichText(
                    text: const TextSpan(
                      text: tPassword,
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  prefixIcon: const Icon(Icons.fingerprint),
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
                    Helper.repeatPassword(value, controller),
                decoration: InputDecoration(
                  errorStyle:
                  const TextStyle(overflow: TextOverflow.visible),
                  errorMaxLines: 3,
                  label: RichText(
                    text: const TextSpan(
                      text: 'Confirm Password',
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  prefixIcon: const Icon(Icons.fingerprint),
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
              Obx(() => TPrimaryButton(
                isLoading: controller.isLoading.value,
                text: tSignup.tr,
                onPressed: () async {
                  if (controller.signupFormKey.currentState!.validate()) {
                    bool usernameExists = await Helper.isUsernameTaken(
                        controller.userName.text);
                    if (usernameExists) {
                      Helper.errorSnackBar(
                          title: 'Error',
                          message: tUserNameAlreadyExists);
                    } else {
                      controller.createUser();
                    }
                  }
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}
