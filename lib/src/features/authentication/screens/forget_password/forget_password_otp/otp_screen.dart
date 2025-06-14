import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fit_office/src/constants/sizes.dart';
import '../../../controllers/otp_controller.dart';
import 'package:fit_office/l10n/app_localizations.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String otp = '';
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(tDefaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.tOtpTitle,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 80.0),
            ),
            Text(AppLocalizations.of(context)!.tOtpSubTitle.toUpperCase(), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 40.0),
            Text("${AppLocalizations.of(context)!.tOtpMessage} support@codingwitht.com", textAlign: TextAlign.center),
            const SizedBox(height: 20.0),
            OtpTextField(
                mainAxisAlignment: MainAxisAlignment.center,
                numberOfFields: 6,
                fillColor: Colors.black.withAlpha((0.1 * 255).toInt()),
                filled: true,
                onSubmit: (code) {
                  otp = code;
                  OTPController.instance.verifyOTP(otp);
                }),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () {
                    OTPController.instance.verifyOTP(otp);
                  },
                  child: Text(AppLocalizations.of(context)!.tNext)),
            ),
          ],
        ),
      ),
    );
  }
}
