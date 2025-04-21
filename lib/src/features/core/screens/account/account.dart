import 'package:fit_office/src/features/core/screens/account/widgets/add_exercises_button.dart';
import 'package:fit_office/src/features/core/screens/account/widgets/delete_user_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/constants/sizes.dart';
import 'package:fit_office/src/constants/text_strings.dart';

import 'widgets/add_friends_button.dart';
import '../../../authentication/models/user_model.dart';
import '../../controllers/profile_controller.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final controller = Get.put(ProfileController());
  late Future<UserModel> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = controller.getUserData();
  }

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(tDefaultSize),
          child: FutureBuilder<UserModel>(
            future: _userFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                final user = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$tAccountGreeting ${user.fullName}', style: txtTheme.headlineSmall),
                    const SizedBox(height: tDefaultSize),
                    if (user.role == "admin") ...[
                      AddExercisesButton(currentUserId: user.id.toString()),
                      const SizedBox(height: tDefaultSize),
                      const DeleteUserButton(),
                      const SizedBox(height: tDefaultSize),
                    ],
                    AddFriendsButton(currentUserId: user.id!),
                  ],
                );
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
