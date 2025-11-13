import 'package:doctor_appointment_app/view/components/Common/button.dart';
import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppointmentBooked extends StatelessWidget {
  const AppointmentBooked({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Lottie.asset(
                'assets/success.json',
                delegates: LottieDelegates(
                  values: [
                    ValueDelegate.color(
                      const ['**'],
                      value: Config.primaryColor,
                    ),

                    // ✅ Then override the checkmark layer to white
                    ValueDelegate.color(
                      const ['check', '**'],
                      value: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                AppLocalizations.of(context)!.successfullyBooked,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsetsGeometry.symmetric(
                horizontal: 10,
                vertical: 15,
              ),
              child: Button(
                width: double.infinity,
                title: AppLocalizations.of(context)!.backToHomePage,
                disabled: false,
                onPressed: () => Navigator.of(context).pushNamed('main'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
