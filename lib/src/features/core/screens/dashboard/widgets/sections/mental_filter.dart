import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/colors.dart';
import 'package:fit_office/src/features/core/models/dashboard/categories_model.dart';

class DashboardMentalSection extends StatelessWidget {
  final List<DashboardCategoriesModel> categories;
  final TextTheme txtTheme;

  const DashboardMentalSection({
    super.key,
    required this.categories,
    required this.txtTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 45,
      child: ListView.builder(
        itemCount: categories.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = categories[index];
          return GestureDetector(
            onTap: item.onPress,
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
                      color: isDark ? Colors.grey[800] : tPrimaryColor.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Text(
                        item.title,
                        style: txtTheme.titleLarge?.apply(color: Colors.white),
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
                          item.heading,
                          style: txtTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item.subHeading,
                          style: txtTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
