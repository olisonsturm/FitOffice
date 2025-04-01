import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:fit_office/src/features/authentication/models/user_model.dart';
import 'package:fit_office/src/features/core/controllers/profile_controller.dart';
import 'package:fit_office/src/features/core/screens/profile/profile_form.dart';
import 'package:fit_office/src/features/core/screens/profile/widgets/image_with_icon.dart';
import '../../../../constants/sizes.dart';
import '../../../../constants/text_strings.dart';

class UpdateProfileScreen extends StatelessWidget {
  UpdateProfileScreen({super.key});

  final controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Get.back(), icon: const Icon(LineAwesomeIcons.angle_left)),
        title: Text(tEditProfile, style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(tDefaultSpace),

          /// -- Future Builder to load cloud data
          child: FutureBuilder(
            future: controller.getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  UserModel user = snapshot.data as UserModel;

                  //Controllers
                  final email = TextEditingController(text: user.email);
                  final password = TextEditingController(text: user.password);
                  final userName = TextEditingController(text: user.userName);
                  final fullName = TextEditingController(text: user.fullName);

                  //Image & Form
                  return Column(
                    children: [
                      /// -- IMAGE with ICON
                      const ImageWithIcon(),
                      const SizedBox(height: 50),

                      /// -- Form (Get data and pass it to FormScreen)
                      ProfileFormScreen(userName: userName, email: email, fullName: fullName, password: password, user: user),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                } else {
                  return const Center(child: Text('Something went wrong'));
                }
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}

