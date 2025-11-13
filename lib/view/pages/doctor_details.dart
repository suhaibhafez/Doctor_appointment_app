import 'package:doctor_appointment_app/view/components/Common/button.dart';
import 'package:doctor_appointment_app/view/components/Common/custom_appbar.dart';
import 'package:doctor_appointment_app/view/components/Common/error_pop_up.dart';
import 'package:doctor_appointment_app/view/components/FacilitiesComponents/facility_map_part.dart';

import 'package:doctor_appointment_app/view/components/Common/shimmer.dart';
import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:doctor_appointment_app/models/Doctor/doctor.dart';

import 'package:doctor_appointment_app/view_model/Doctor/doctor_by_id.dart';

import 'package:doctor_appointment_app/routes/routes.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/utils/enums/specialitiez_facilities.dart';
import 'package:doctor_appointment_app/view_model/Facility/facility_by_id.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';

class DoctorDetails extends ConsumerWidget {
  DoctorDetails({super.key}) : docId = Get.parameters['id'] ?? '';
  final String docId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Config().init(context);
    if (docId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Invalid doctor ID'),
        ),
      );
    }

    final doctorAsync = ref.watch(doctorByIdProvider(docId));
    return Scaffold(
      appBar: CustomAppbar(
        appTitle: AppLocalizations.of(context)!.doctorDetails,
        icon: const FaIcon(Icons.arrow_back_ios),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: doctorAsync.when(
            loading: () => const DoctorDetailsShimmer(),
            error: (err, stack) => Center(
              child: Text(
                'Error: $err',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            data: (data) => Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        AboutDoctor(doctor: data),
                        Config.spaceSmall,
                        ref
                            .watch(
                              facilityByIdProvider(data.healthCareFacilityId!),
                            )
                            .when(
                              loading: () => const FacilityMapShimmer(),
                              error: (err, stack) => ErrorPopUp(
                                title: 'Something went wrong ',
                                content: 'try reloading ',
                                buttonText: 'Retry',
                                onOk: () async => ref.invalidate(
                                  facilityByIdProvider(
                                    data.healthCareFacilityId!,
                                  ),
                                ),
                              ),
                              data: (facility) => FacilityMapPart(
                                lat: facility.gpsLatitude!,
                                long: facility.gpsLongitude!,
                              ),
                            ),
                        Config.spaceMedium,
                      ],
                    ),
                  ),
                ),
                Button(
                  height: 48,
                  width: double.infinity,
                  title: AppLocalizations.of(context)!.bookAppointment,
                  disabled: false,
                  onPressed: () async {
                    await Get.toNamed(Sroutes.bookingPage);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AboutDoctor extends StatelessWidget {
  const AboutDoctor({super.key, required this.doctor});
  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Column(
      children: [
        Hero(
          tag: doctor.id,
          child: Container(
            margin: const EdgeInsets.all(12),
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Config.primaryColor, width: 2),
              image: const DecorationImage(
                image: NetworkImage(
                  // doctor.imageUrl ??
                  'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Config.spaceSmall,
        Text(
          '${AppLocalizations.of(context)!.dr} ${doctor.firstName} ${doctor.lastName}',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Config.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          getLocalizedSpe(doctor.specialization, context, false),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Config.spaceSmall,
      ],
    );
  }
}
