import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../../constants/sizes.dart';
import '../../../../constants/text_strings.dart';
import '../../../authentication/models/user_model.dart';
import '../../controllers/profile_controller.dart';


class ProfileFormScreen extends StatelessWidget {
  const ProfileFormScreen({
    super.key,
    required this.user,
    required this.email,
    required this.phoneNo,
    required this.fullName,
    required this.password,
  });

  final UserModel user;
  final TextEditingController email;
  final TextEditingController phoneNo;
  final TextEditingController fullName;
  final TextEditingController password;

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(ProfileController());

    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: fullName,
            decoration: const InputDecoration(label: Text(tFullName), prefixIcon: Icon(LineAwesomeIcons.user)),
          ),
          const SizedBox(height: tFormHeight - 20),
          TextFormField(
            controller: email,
            decoration: const InputDecoration(label: Text(tEmail), prefixIcon: Icon(LineAwesomeIcons.envelope_1)),
          ),
          const SizedBox(height: tFormHeight - 20),
          TextFormField(
            controller: phoneNo,
            decoration: const InputDecoration(label: Text(tPhoneNo), prefixIcon: Icon(LineAwesomeIcons.phone)),
          ),
          const SizedBox(height: tFormHeight),

          /// -- Form Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final userData = UserModel(
                  id: user.id,
                  email: email.text.trim(),
                  fullName: fullName.text.trim(),
                  phoneNo: phoneNo.text.trim(),
                );

                await controller.updateRecord(userData);
              },
              child: const Text(tEditProfile),
            ),
          ),
          const SizedBox(height: tFormHeight),

          /// -- Created Date and Delete Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text.rich(
                TextSpan(
                  text: tJoined,
                  style: TextStyle(fontSize: 12),
                  children: [TextSpan(text: tJoinedAt, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    elevation: 0,
                    foregroundColor: Colors.red,
                    side: BorderSide.none),
                child: const Text(tDelete),
              ),
            ],
          )
        ],
      ),
    );
  }
}