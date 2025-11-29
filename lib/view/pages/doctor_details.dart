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
import 'package:doctor_appointment_app/view_model/Doctor/doctor_schedule.dart';
import 'package:doctor_appointment_app/view_model/Doctor/doctor_schedule_exception.dart';
import 'package:doctor_appointment_app/view_model/Facility/facility_by_id.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
                        DoctorExceptionScheduleSection(doctorId: data.id),
                        Config.spaceSmall,
                        if ((data.numbers != null &&
                                data.numbers!.isNotEmpty) ||
                            (data.emails != null &&
                                data.emails!.isNotEmpty)) ...[
                          DoctorContactSection(doctor: data),
                          Config.spaceSmall,
                        ],

                        DoctorScheduleSection(doctorId: data.id),

                        ref
                            .watch(
                              facilityByIdProvider(data.healthCareFacilityId!),
                            )
                            .when(
                              loading: () => const FacilityMapShimmer(),
                              error: (err, stack) => ErrorPopUp(
                                title: 'Something went wrong ',
                                content: err.toString(),
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
                    await Get.toNamed(
                      Sroutes.bookingPage,
                      parameters: {
                        'docId': data.id,
                        'facId': data.healthCareFacilityId!,
                      },
                    );
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
    final isSmall = Config.screenWidth! < 360;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
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
              image: DecorationImage(
                image: doctor.avatar == null || doctor.avatar!.isEmpty
                      ? const AssetImage(
                        'assets/dummyDoctor.png',
                      )
                    : NetworkImage(
                  
                       Config.getImageUrlForID(doctor.avatar!),
                       headers: {
                    
                      'ngrok-skip-browser-warning': '1',
                  },
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Text(
              getLocalizedSpe(doctor.specialization, context, false),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: Colors.amber.shade600,
                  size: isSmall ? 16 : 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${doctor.rating}',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontSize: isSmall ? 12 : 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(width: 4),
                Text(
                  '(${doctor.totalRatings})',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontSize: isSmall ? 11 : 13,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ],
        ),
        Config.spaceSmall,
        if (doctor.description != null && doctor.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.grey.shade300,
                ),
              ),
              child: Text(
                doctor.description!,
                textAlign: TextAlign.left,
                style: theme.textTheme.bodyMedium!.copyWith(
                  height: 1.5,
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class DoctorContactSection extends StatelessWidget {
  final Doctor doctor;

  const DoctorContactSection({super.key, required this.doctor});

  Future<void> launchEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Hello', 'body': ''},
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Config().init(context);
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: false,
        iconColor: Config.primaryColor,
        collapsedIconColor: Config.primaryColor,
        textColor: Config.primaryColor,
        collapsedTextColor: theme.textTheme.bodyLarge!.color,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        tilePadding: const EdgeInsets.all(0),

        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 6,
          children: [
            const Icon(Icons.mail_outline),
            Text(
              AppLocalizations.of(context)!.contacts,
              style: theme.textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        children: [
          // Title

          // -------------------- EMAILS --------------------
          if (doctor.emails != null && doctor.emails!.isNotEmpty) ...[
            const SizedBox(height: 12),

            Text(
              AppLocalizations.of(context)!.emails,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            ...doctor.emails!.map((e) {
              final bool isPrimary = e.isPrimary;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? Config.accentColor.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPrimary
                        ? Config.accentColor
                        : Colors.grey.shade400,
                    width: isPrimary ? 1.6 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: isPrimary ? Config.accentColor : Colors.grey,
                      size: 10,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.label,
                            style: TextStyle(
                              fontSize: 13,
                              color: isPrimary
                                  ? Config.primaryColor
                                  : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            e.email,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        elevation: 2,
                      ),
                      onPressed: () async => await launchEmail(e.email),
                      icon: const Icon(Icons.email_outlined, size: 16),
                      label: Text(
                        AppLocalizations.of(context)!.send,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          // -------------------- PHONE NUMBERS --------------------
          if (doctor.numbers != null && doctor.numbers!.isNotEmpty) ...[
            const SizedBox(height: 16),

            Text(
              AppLocalizations.of(context)!.phoneNumbers,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            ...doctor.numbers!.map((p) {
              final bool isPrimary = p.isPrimary;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? Config.accentColor.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPrimary
                        ? Config.accentColor
                        : Colors.grey.shade400,
                    width: isPrimary ? 1.6 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: isPrimary ? Config.accentColor : Colors.grey,
                      size: 10,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.label,
                            style: TextStyle(
                              fontSize: 13,
                              color: isPrimary
                                  ? Config.primaryColor
                                  : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            p.email,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // Widget _buildListSection({
  //   required String title,
  //   required List items,
  //   required IconData icon,
  //   required ThemeData theme,
  //   required bool isEmail,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         title,
  //         style: theme.textTheme.bodyLarge!.copyWith(
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       const SizedBox(height: 8),

  //       ...items.map((item) {
  //         final bool primary = item.isPrimary;

  //         return Container(
  //           margin: const EdgeInsets.only(bottom: 8),
  //           padding: const EdgeInsets.all(12),
  //           decoration: BoxDecoration(
  //             color: primary
  //                 ? theme.colorScheme.primary.withOpacity(0.15)
  //                 : theme.cardTheme.color,
  //             borderRadius: BorderRadius.circular(12),
  //             border: Border.all(
  //               color: primary
  //                   ? Config.primaryColor
  //                   : Colors.grey.withOpacity(0.3),
  //             ),
  //           ),
  //           child: Row(
  //             children: [
  //               Icon(
  //                 icon,
  //                 color: primary ? Config.primaryColor : Colors.grey,
  //               ),
  //               const SizedBox(width: 12),

  //               // Value
  //               Expanded(
  //                 child: Text(
  //                   isEmail ? item.email : item.email,
  //                   style: theme.textTheme.bodyLarge!.copyWith(
  //                     fontWeight: primary ? FontWeight.bold : FontWeight.normal,
  //                     fontSize: 15,
  //                   ),
  //                 ),
  //               ),

  //               if (primary)
  //                 Container(
  //                   padding: const EdgeInsets.symmetric(
  //                     horizontal: 8,
  //                     vertical: 4,
  //                   ),
  //                   decoration: BoxDecoration(
  //                     color: Config.primaryColor,
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                   child: const Text(
  //                     "Primary",
  //                     style: TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 12,
  //                     ),
  //                   ),
  //                 ),
  //             ],
  //           ),
  //         );
  //       }),
  //     ],
  //   );
  // }
}

class DoctorScheduleSection extends ConsumerWidget {
  final String doctorId;

  const DoctorScheduleSection({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(doctorScheduleProvider(doctorId));
    final theme = Theme.of(context);
    final dayOrder = {
      'Saturday': 0,
      'Sunday': 1,
      'Monday': 2,
      'Tuesday': 3,
      'Wednesday': 4,
      'Thursday': 5,
      'Friday': 6,
    };

    return scheduleAsync.when(
      loading: () => const SizedBox.shrink(),
      //TODO Localize
      error: (err, stack) => Text(
        'Failed to load schedule',
        style: theme.textTheme.bodyLarge!.copyWith(color: Colors.red),
      ),
      data: (schedule) {
        if (schedule.isEmpty) {
          return const SizedBox.shrink();
        }

        schedule.sort(
          (a, b) => dayOrder[a.dayOfWeek]!.compareTo(dayOrder[b.dayOfWeek]!),
        );

        return Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            iconColor: Config.primaryColor,
            collapsedIconColor: Config.primaryColor,
            textColor: Config.primaryColor,
            collapsedTextColor: theme.textTheme.bodyLarge!.color,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            tilePadding: const EdgeInsets.all(0),

            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 4,
              children: [
                const Icon(FontAwesomeIcons.solidCalendarCheck),
                Text(
                  AppLocalizations.of(context)!.schedule,
                  style: theme.textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            children: schedule.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.circle,
                      color: Config.accentColor,
                      size: 10,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.dayOfWeek,
                            style: theme.textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${item.startTime} - ${item.endTime}",
                            style: theme.textTheme.bodyMedium,
                          ),
                          if (item.note.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                item.note,
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class DoctorExceptionScheduleSection extends ConsumerWidget {
  final String doctorId;

  const DoctorExceptionScheduleSection({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(doctorScheduleExceptionProvider(doctorId));
    final theme = Theme.of(context);

    return scheduleAsync.when(
      loading: () => const SizedBox.shrink(),
      //TODO localize
      error: (err, stack) => Text(
        'Failed to load schedule',
        style: theme.textTheme.bodyLarge!.copyWith(color: Colors.red),
      ),
      data: (schedule) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final filtered = schedule.where(
          (e) {
            final date = e.date;
            return date.isAtSameMomentAs(today) || date.isAfter(today);
          },
        ).toList();
        if (filtered.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //TODO localize
            const Text(
              '*note:doctor doesnt work at this time',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            ...filtered.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    const Icon(
                      Icons.circle,
                      color: Config.errorColor,
                      size: 10,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('yyyy-MM-dd').format(item.date),
                            style: theme.textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${item.startTime} - ${item.endTime}",
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
