import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../../constants/colors.dart';
import '../../../../authentication/models/user_model.dart';
import '../../../controllers/db_controller.dart';
import '../../../controllers/profile_controller.dart';

class ActiveStreakWidget extends StatelessWidget{
  const ActiveStreakWidget({
    super.key,
    required this.txtTheme,
    required this.isDark,
  });

  final TextTheme txtTheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return FutureBuilder(
      future: controller.getUserData(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (userSnapshot.hasData) {
          final user = userSnapshot.data as UserModel;
          final dbController = DbController()..user = user;

          return FutureBuilder<String?>(
            future: dbController.fetchActiveStreakSteps(),
            builder: (context, stepsSnapshot) {
              if (stepsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (stepsSnapshot.hasData && stepsSnapshot.data != null) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: isDark ? tSecondaryColor : tCardBgColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orange, size: 40),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aktiver Streak',
                            style: txtTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${stepsSnapshot.data}',
                            style: txtTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              } else {
                return const Text('Kein aktiver Streak gefunden.');
              }
            },
          );
        } else {
          return const Text('Fehler beim Laden der Nutzerdaten.');
        }
      },
    );
  }
}