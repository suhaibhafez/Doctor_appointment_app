import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:doctor_appointment_app/models/Doctor/doctor.dart';
import 'package:doctor_appointment_app/routes/routes.dart';
import 'package:doctor_appointment_app/utils/config.dart';

import 'package:doctor_appointment_app/utils/enums/specialitiez_facilities.dart';
import 'package:doctor_appointment_app/view/components/Common/cool_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorCard({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    Config().init(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 360; // small screen detection

        return GestureDetector(
          onTap: () async {
            await Get.toNamed('${Sroutes.docDetails}/${doctor.id}');
          },
          child: Container(
            height: Config.screenHeight! * 0.2,
            padding: const EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Config.surfaceDark : Config.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Doctor image avatar
                  Hero(
                    tag: doctor.id,
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      width: isSmall ? 55 : 70,
                      height: isSmall ? 55 : 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Config.primaryColor,
                          width: 2,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(
                            doctor.avatar == null || doctor.avatar!.isEmpty
                                ? 'https://cdn-icons-png.flaticon.com/512/3774/3774299.png'
                                : Config.getImageUrlForID(doctor.avatar!),
                            headers: {
                              if (doctor.avatar != null &&
                                  doctor.avatar!.isNotEmpty)
                                'ngrok-skip-browser-warning': '1',
                            },
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  // Text section
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 6,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Doctor name
                          Text(
                            'Dr. ${doctor.firstName} ${doctor.lastName}',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge!.copyWith(
                              fontSize: isSmall ? 15 : 17,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Config.textLight
                                  : Config.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Specialization
                          Row(
                            children: [
                              Icon(
                                getLocalizedSpe(
                                  doctor.specialization,
                                  context,
                                  true,
                                ),
                                size: 14,
                                color: Config.primaryColor.withOpacity(0.8),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  getLocalizedSpe(
                                    doctor.specialization,
                                    context,
                                    false,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    fontSize: isSmall ? 13 : 14,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Rating
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: Colors.amber.shade600,
                                size: isSmall ? 16 : 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${doctor.rating == 0.0 ? 3.0 : doctor.rating}',
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  fontSize: isSmall ? 12 : 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${doctor.totalRatings == 0 ? 178 : doctor.totalRatings})',
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
                    ),
                  ),

                  // Action button
                  Container(
                    padding: const EdgeInsets.all(8),

                    alignment: AlignmentGeometry.bottomLeft,
                    child: CoolButton(
                      isSmall: true,
                      text: AppLocalizations.of(context)!.bookAppointment,
                      onclick: () async {
                        await Get.toNamed(
                          '${Sroutes.docDetails}/${doctor.id}',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
