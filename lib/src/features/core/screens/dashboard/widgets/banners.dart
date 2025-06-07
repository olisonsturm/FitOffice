import 'package:flutter/material.dart';
import '../../../../../constants/colors.dart';
import '../../../../../constants/image_strings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fit_office/src/constants/sizes.dart';

class DashboardBanners extends StatelessWidget {
  const DashboardBanners({
    super.key,
    required this.txtTheme,
    required this.isDark,
  });

  final TextTheme txtTheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: tDashboardCardPadding),
        //1st banner
        Expanded(
          child: GestureDetector(
          onTap: () {
            // Insert link to information page for long-term health here
            //Navigator.pushNamed(context, '/detailPage');
          },
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
              //For Dark Color
              color: isDark ? tSecondaryColor : tCardBgColor,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Image(image: AssetImage(tBookmarkIcon))),
                    Flexible(child: Icon(Icons.monitor_heart, size: 50,)),
                  ],
                ),
                const SizedBox(height: 25),
                Text(AppLocalizations.of(context)!.tDashboardBannerTitle1, style: txtTheme.headlineMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(AppLocalizations.of(context)!.tDashboardBannerSubTitle, style: txtTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          ),
        ),
        const SizedBox(width: tDashboardCardPadding),
        //2nd Banner
        Expanded(
          child: GestureDetector(
            onTap: () {
              // Insert link to information page for short-term health here
              //Navigator.pushNamed(context, '/detailPage');
            },
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),
                //For Dark Color
                color: isDark ? tSecondaryColor : tCardBgColor,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: Image(image: AssetImage(tBookmarkIcon))),
                      Flexible(child: Icon(Icons.bolt, size: 50,)),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text(AppLocalizations.of(context)!.tDashboardBannerTitle2, style: txtTheme.headlineMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                  Text(AppLocalizations.of(context)!.tDashboardBannerSubTitle, style: txtTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
