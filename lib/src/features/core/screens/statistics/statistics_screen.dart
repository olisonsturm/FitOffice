import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/sizes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fit_office/src/features/core/screens/dashboard/widgets/statistics.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  StatisticScreenState createState() => StatisticScreenState();
}

class StatisticScreenState extends State<StatisticScreen> {
  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(tDashboardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.tDashboardStatistics,
              style: txtTheme.headlineMedium
                  ?.apply(fontSizeFactor: 1.2)),
          const SizedBox(height: 20),
          StatisticsWidget(txtTheme: txtTheme, isDark: isDark),
        ],
      ),
    );
  }
}