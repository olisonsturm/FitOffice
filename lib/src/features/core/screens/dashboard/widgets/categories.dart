import 'package:fit_office/src/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';

import '../../../controllers/db_controller.dart';
import '../../../models/dashboard/categories_model.dart';

class DashboardCategories extends StatefulWidget {
  const DashboardCategories({
    super.key,
    required this.txtTheme,
  });

  final TextTheme txtTheme;

  @override
  State<DashboardCategories> createState() => _DashboardCategoriesState();
}

class _DashboardCategoriesState extends State<DashboardCategories> {
  final DbController _dbController = DbController();
  String upperBodyCount = '';
  String lowerBodyCount = '';
  String fullBodyCount = '';
  String psychologicalCount = '';

  @override
  void initState() {
    super.initState();
    _loadExerciseCount();
  }

  void _loadExerciseCount() async {
    String countUpperBody = await _dbController.getNumberOfExercisesUpperBody();
    String countLowerBody = await _dbController.getNumberOfExercisesLowerBody();
    String countFullBody = await _dbController.getNumberOfExercisesFullBody();
    String countPsychological = await _dbController.getNumberOfPsychologicalExercises();
    setState(() {
      upperBodyCount = "$countUpperBody Einheiten";
      lowerBodyCount = "$countLowerBody Einheiten";
      fullBodyCount = "$countFullBody Einheiten";
      psychologicalCount = "$countPsychological Einheiten";
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = [
      DashboardCategoriesModel("OK", "Oberkörper", upperBodyCount, null),
      DashboardCategoriesModel("UK", "Unterkörper", lowerBodyCount, null),
      DashboardCategoriesModel("GK", "Ganzkörper", fullBodyCount, null),
    ];
    
    final listPsychologicalExercises = [
      DashboardCategoriesModel("🧠", "Geist", psychologicalCount, null),
    ];

    final listFavouriteExercises = DashboardCategoriesModel.listFavouriteExercises;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          tDashboardPhysicalExercisesTitle,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 45,
          child: ListView.builder(
            itemCount: list.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => GestureDetector(
              onTap: list[index].onPress,
              child: SizedBox(
                width: 170,
                height: 45,
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: tDarkColor,
                      ),
                      child: Center(
                        child: Text(
                          list[index].title,
                          style: widget.txtTheme.titleLarge?.apply(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            list[index].heading,
                            style: widget.txtTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            list[index].subHeading,
                            style: widget.txtTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Psychological Exercises
        const Text(
          tDashboardPsychologicalExercisesTitle,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 45,
          child: ListView.builder(
            itemCount: listPsychologicalExercises.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => GestureDetector(
              onTap: listPsychologicalExercises[index].onPress,
              child: SizedBox(
                width: 170,
                height: 45,
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: tDarkColor,
                      ),
                      child: Center(
                        child: Text(
                          listPsychologicalExercises[index].title,
                          style: widget.txtTheme.titleLarge?.apply(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            listPsychologicalExercises[index].heading,
                            style: widget.txtTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            listPsychologicalExercises[index].subHeading,
                            style: widget.txtTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Favourite Exercises
        const Text(
          tDashboardFavouriteExercises,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 45,
          child: ListView.builder(
            itemCount: listFavouriteExercises.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => GestureDetector(
              onTap: listFavouriteExercises[index].onPress,
              child: SizedBox(
                width: 170,
                height: 45,
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: tDarkColor,
                      ),
                      child: Center(
                        child: Text(
                          listFavouriteExercises[index].title,
                          style: widget.txtTheme.titleLarge?.apply(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            listFavouriteExercises[index].heading,
                            style: widget.txtTheme.titleLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            listFavouriteExercises[index].subHeading,
                            style: widget.txtTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
