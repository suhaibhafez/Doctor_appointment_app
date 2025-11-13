import 'package:doctor_appointment_app/routes/routes.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/utils/enums/specialitiez_facilities.dart';
import 'package:doctor_appointment_app/view/components/AppointmentsComponents/appointment_card.dart';
import 'package:doctor_appointment_app/view/components/Common/shimmer.dart';
import 'package:doctor_appointment_app/view_model/Appointment/appointments_today.dart';

import 'package:doctor_appointment_app/view_model/Patient/patient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    Config().init(context);
    final patientAsync = ref.watch(patientNotifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 24,
              children: [
                // 🔹 Header Section (Logo + Patient Info)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [patientAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(
                      child: Text(
                        'Error loading patient data',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    data: (patient) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          '${patient!.firstName} ${patient.lastName}',
                          style: Theme.of(context).textTheme.headlineSmall!
                              .copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          patient.nationalId,
                          style: Theme.of(context).textTheme.titleSmall!
                              .copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                      Image.asset(
                      'assets/logo.png',
                      width: Config.screenWidth! * 0.10,
                      height: Config.screenWidth! * 0.10,
                      fit: BoxFit.contain,
                    ),
                  ]
                ),
              
                Text(
                  'Today\'s Appointments',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const AppointmentsTodayList(),

                // 🔹 Specialities Section
                Text(
                  'Explore Specialities',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(
                  height: Config.screenHeight! * 0.1,
                  child: const SpecialitiesList(),
                ),

                // 🔹 Facilities Section
                Text(
                  'Nearby Facilities',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(
                  height: Config.screenHeight! * 0.1,
                  child: const FacilitiesList(),
                ),

                // 🔹 Top Doctors Section (Placeholder for now)
                Text(
                  'Top Doctors',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Container(
                  width: double.infinity,
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    'Coming Soon...',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SpecialitiesList extends StatelessWidget {
  const SpecialitiesList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final specialities = getSpecialitiesList(
      context,
    ).sublist(1);
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,

      itemCount: specialities.length,
      itemBuilder: (context, index) {
        final speciality = specialities[index];
        return SpecialityItem(
          icon: speciality["icon"],
          category: speciality["category"],
          onTap: () async {
            await Get.toNamed(
              Sroutes.doctorsBySpecialityPage,
              arguments: index + 1,
            );
          },
        );
      },
    );
  }
}

class FacilitiesList extends StatelessWidget {
  const FacilitiesList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final facilities = getFacilityTypesList(
      context,
    );
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,

      itemCount: facilities.length,
      itemBuilder: (context, index) {
        final facilitiy = facilities[index];
        return SpecialityItem(
          icon: facilitiy["icon"],
          category: facilitiy["category"],
          onTap: () async {
            await Get.toNamed(
              Sroutes.facilitiesByTypePage,
              arguments: index,
            );
          },
        );
      },
    );
  }
}

class AppointmentsTodayList extends ConsumerWidget {
  const AppointmentsTodayList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Config().init(context);
    final appointmentsToday = ref.watch(appointmentstodayProvider);
    return appointmentsToday.when(
      data: (appointments) {
        if (appointments.isEmpty) {
          return const NoAppointmentsCard();
        }
        return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            return SizedBox(
              height: Config.screenHeight! * 0.4,

              width: Config.screenWidth! * 0.65,
              child: AppointmentCard(appointment: appointment),
            );
          },
        );
      },
      loading: () => const ShimmerAppointmentCard(),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class SpecialityItem extends StatelessWidget {
  final IconData icon;
  final String category;
  final VoidCallback onTap;

  const SpecialityItem({
    super.key,
    required this.icon,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? Config.surfaceDark : Config.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Config.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                category,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Config.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoAppointmentsCard extends StatelessWidget {
  const NoAppointmentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width:double.infinity,

      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey.shade300,
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            FontAwesomeIcons.solidCalendarCheck,
            size: 40,
            color: Config.primaryColor,
          ),
          const SizedBox(height: 12),
          Text(
            'No Appointments Today',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You’re all caught up for the day!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
