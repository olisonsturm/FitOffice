import 'package:flutter/material.dart';
import 'package:fit_office/src/constants/sizes.dart';
import 'package:fit_office/src/features/core/screens/statistics/widgets/statistics.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  StatisticScreenState createState() => StatisticScreenState();
}

class StatisticScreenState extends State<StatisticScreen> {
  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(tDashboardPadding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatisticsWidget(txtTheme: txtTheme),
            const SizedBox(height: 20), // Extra padding at bottom
          ],
        ),
      ),
    );
  }
}