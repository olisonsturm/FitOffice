import 'package:fit_office/src/features/core/screens/account/widgets/all_users.dart';
import 'package:fit_office/src/features/core/screens/account/widgets/friends_box.dart';
import 'package:fit_office/src/features/core/screens/account/widgets/friends_request.dart';
import 'package:fit_office/src/features/core/screens/account/widgets/navigation_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_office/src/constants/sizes.dart';
import 'package:fit_office/src/constants/text_strings.dart';

import 'add_exercises.dart';
import 'edit_user_page.dart';
import 'widgets/add_friends_button.dart';
import '../../../authentication/models/user_model.dart';
import '../../controllers/profile_controller.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<AccountScreen> {
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
                      NavigationButton(
                        icon: Icons.add,
                        label: tAddExercises,
                        destinationBuilder: (context) => AddExercises(currentUserId: user.id!),
                      ),
                      const SizedBox(height: tDefaultSize),
                      NavigationButton(
                        icon: Icons.delete,
                        label: tDeleteEditUser,
                        destinationBuilder: (context) => const AllUsersPage(),
                      ),
                      const SizedBox(height: tDefaultSize),
                      NavigationButton(
                        icon: Icons.person_add,
                        label: tAddUser,
                        destinationBuilder: (context) => const EditUserPage(),
                      ),
                      const SizedBox(height: tDefaultSize),
                    ],
                    AddFriendsButton(currentUserId: user.id!),
                    const SizedBox(height: tDefaultSize),
                    FriendsBoxWidget(currentUserId: user.id!),
                    const SizedBox(height: tDefaultSize),
                    FriendRequestsWidget(currentUserId: user.id!),
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
