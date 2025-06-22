import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:fit_office/src/constants/sizes.dart';
import 'package:fit_office/src/repository/authentication_repository/authentication_repository.dart';

import 'package:fit_office/l10n/app_localizations.dart';
import '../../controllers/mail_verification_controller.dart';

/// MailVerification widget that displays a screen for email verification.
class MailVerification extends StatelessWidget {
  const MailVerification({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MailVerificationController());
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
              top: tDefaultSpace * 5, left: tDefaultSpace, right: tDefaultSpace, bottom: tDefaultSpace * 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LineAwesomeIcons.envelope_open, size: 100),
              const SizedBox(height: tDefaultSpace * 2),
              Text(AppLocalizations.of(context)!.tEmailVerificationTitle.tr, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: tDefaultSpace),
              Text(
                AppLocalizations.of(context)!.tEmailVerificationSubTitle.tr,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: tDefaultSpace * 2),
              SizedBox(
                width: 200,
                child: OutlinedButton(child: Text(AppLocalizations.of(context)!.tContinue.tr), onPressed: () => controller.manuallyCheckEmailVerificationStatus()),
              ),
              const SizedBox(height: tDefaultSpace * 2),
              TextButton(
                onPressed: () => controller.sendVerificationEmail(),
                child: Text(AppLocalizations.of(context)!.tResendEmailLink.tr),
              ),
              TextButton(
                onPressed: () => AuthenticationRepository.instance.logout(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LineAwesomeIcons.long_arrow_alt_left_solid),
                    const SizedBox(width: 5),
                    Text(AppLocalizations.of(context)!.tBackToLogin.tr.toLowerCase()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
