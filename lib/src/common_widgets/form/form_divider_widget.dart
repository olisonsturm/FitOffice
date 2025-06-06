import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TFormDividerWidget extends StatelessWidget {
  const TFormDividerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Row(
      children: [
        Flexible(child: Divider(thickness: 1, indent: 50, color: Colors.grey.withAlpha((0.3 * 255).toInt()), endIndent: 10)),
        Text(AppLocalizations.of(context)!.tOR, style: Theme.of(context).textTheme.bodyLarge!.apply(color: isDark ? tWhiteColor.withAlpha((0.5 * 255).toInt()) : tDarkColor.withAlpha((0.5 * 255).toInt()))),
        Flexible(child: Divider(thickness: 1, indent: 10, color: Colors.grey.withAlpha((0.3 * 255).toInt()), endIndent: 50)),
      ],
    );
  }
}
