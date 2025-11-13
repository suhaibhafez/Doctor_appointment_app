import 'package:doctor_appointment_app/routes/routes.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/utils/enums/specialitiez_facilities.dart';
import 'package:doctor_appointment_app/view/components/Common/cool_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doctor_appointment_app/models/Facility/facility.dart';

class FacilityCard extends StatelessWidget {
  final Facility facility;

  const FacilityCard({
    super.key,
    required this.facility,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconName = getFacilityTypesList(context).asMap().entries.firstWhere(
      (element) => element.key == facility.type,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 360; // Detect small screens

        return GestureDetector(
          onTap: () async {
            await Get.toNamed('${Sroutes.facilityDetails}/${facility.id}');
          },
          child: Container(
            height: Config.screenHeight! * 0.18,
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
                  // Facility icon
                  Container(
                    margin: const EdgeInsets.all(12),
                    width: isSmall ? 55 : 70,
                    height: isSmall ? 55 : 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Config.primaryColor, width: 2),
                      color: Config.accentColor.withOpacity(0.1),
                    ),
                    child: Icon(
                      iconName.value['icon'],
                      size: isSmall ? 28 : 40,
                      color: Config.primaryColor,
                    ),
                  ),

                  // Facility info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Facility name
                          Text(
                            facility.name,
                            style: theme.textTheme.labelLarge!.copyWith(
                              fontSize: isSmall ? 15 : 17,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Config.textLight
                                  : Config.textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Category
                          Text(
                            iconName.value['category'],
                            style: theme.textTheme.bodyMedium!.copyWith(
                              fontSize: isSmall ? 13 : 14,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Address
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: isSmall ? 14 : 16,
                                color: Config.primaryColor.withOpacity(0.8),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${facility.street}, ${facility.city}, ${facility.country}',
                                  style: theme.textTheme.bodyMedium!.copyWith(
                                    fontSize: isSmall ? 12 : 11,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // More button
                  Container(
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.bottomRight,
                    child: CoolButton(
                      isSmall: isSmall,
                      onclick: () async {
                        await Get.toNamed(
                          '${Sroutes.facilityDetails}/${facility.id}',
                        );
                      },
                      text: 'More',
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
