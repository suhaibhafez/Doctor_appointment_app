import 'package:carousel_slider/carousel_slider.dart';
import 'package:doctor_appointment_app/l10n/app_localizations.dart';
// import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:doctor_appointment_app/models/Facility/facility.dart';
import 'package:doctor_appointment_app/models/Facility/facility_exception_schedule.dart';
import 'package:doctor_appointment_app/models/Facility/facility_schedule.dart';
import 'package:doctor_appointment_app/view/pages/home_page.dart';
import 'package:doctor_appointment_app/view_model/Facility/departments.dart';
import 'package:doctor_appointment_app/view_model/Facility/doctors_in_department.dart';
import 'package:doctor_appointment_app/view_model/Facility/facilities_upload.dart';
import 'package:doctor_appointment_app/view_model/Facility/facility_by_id.dart';
import 'package:doctor_appointment_app/utils/config.dart';

import 'package:doctor_appointment_app/view/components/Common/custom_appbar.dart';
import 'package:doctor_appointment_app/view/components/DoctorsComponents/doctor_card.dart';
import 'package:doctor_appointment_app/view/components/FacilitiesComponents/facility_map_part.dart';
import 'package:doctor_appointment_app/view/components/Common/shimmer.dart';
import 'package:doctor_appointment_app/view/pages/search_page.dart';
import 'package:flutter/material.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/route_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class FacilityDetails extends ConsumerWidget {
  FacilityDetails({super.key}) : facilityId = Get.parameters['id'] ?? '';
  final String facilityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Config().init(context);

    if (facilityId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('Invalid Facility ID'),
        ),
      );
    }

    final facilityAsync = ref.watch(facilityByIdProvider(facilityId));

    return Scaffold(
      appBar: CustomAppbar(
        appTitle: AppLocalizations.of(context)!.localeName == 'en'
            ? 'Facility Details'
            : 'تفاصيل المرفق',
        icon: const FaIcon(Icons.arrow_back_ios),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: facilityAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  Config.spaceSmall,
                  Text(
                    'Unable to load facility details',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    'Error: $err',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            data: (facility) => _FacilityContent(facility: facility),
          ),
        ),
      ),
    );
  }
}

class _FacilityContent extends StatelessWidget {
  final Facility facility;
  const _FacilityContent({required this.facility});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Facility Header with Map
          _FacilityHeaderCard(facility: facility),

          // Exception Schedules (if any)
          FacilityExceptionScheduleSection(
            schedule: facility.expSchedules!,
          ),

          // Regular Schedules
          FacilityScheduleSection(schedule: facility.schedules!),
          Config.spaceMedium,

          // Facility Images/Gallery
          FacilityUploads(facilityId: facility.id),
          Config.spaceMedium,

          // Departments
          _DepartmentsPart(facilityId: facility.id),

          Config.spaceBig, // Extra spacing at bottom
        ],
      ),
    );
  }
}

// 🏥 Facility Header Card with Map
class _FacilityHeaderCard extends StatelessWidget {
  final Facility facility;
  const _FacilityHeaderCard({required this.facility});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: theme.colorScheme.surface,
      child: Container(
        width: double.infinity, // Ensure full width
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Facility Name
            Text(
              facility.name,
              textAlign: TextAlign.left,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),

            const SizedBox(height: 16),

            // Facility Details
            _FacilityDetailRow(
              icon: Icons.location_on_outlined,
              text: facility.fullAddress!,
            ),
            const SizedBox(height: 8),

            _FacilityDetailRow(
              icon: Icons.public,
              text: "${facility.city}, ${facility.country}",
            ),
            const SizedBox(height: 8),

            // _FacilityDetailRow(
            //   icon: Icons.local_hospital_outlined,
            //   text: "Type: ${facility.type}",
            // ),
            const SizedBox(height: 20),

            // Map Section
            FacilityMapPart(
              lat: facility.gpsLatitude!,
              long: facility.gpsLongitude!,
            ),
          ],
        ),
      ),
    );
  }
}

// 🏥 Facility Detail Row Component
class _FacilityDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FacilityDetailRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// 🏥 Departments + Doctors Section
class _DepartmentsPart extends HookConsumerWidget {
  final String facilityId;
  const _DepartmentsPart({required this.facilityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedIndex = useState(0);
    final departmentAsync = ref.watch(departmentsProvider(facilityId));
    final t = AppLocalizations.of(context)!;
    return departmentAsync.when(
      data: (departments) {
        if (departments.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Departments Header with Icon
            Row(
              children: [
                Icon(
                  Icons.business_outlined,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  t.medicalDepartments,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              t.browseDepartmentsAndFindSpecializedDoctors,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),

            // Departments Tab Bar
            SizedBox(
              height: 50,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                scrollDirection: Axis.horizontal,
                itemCount: departments.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return InkWell(
                    overlayColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    onTap: () {
                      selectedIndex.value = index;
                    },
                    child: buildCustomTab(
                      context,
                      selectedIndex.value,
                      index: index,
                      label: departments[index].name,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Department Description
            if (departments[selectedIndex.value].description.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: theme.colorScheme.primary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${t.about} ${departments[selectedIndex.value].name}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                departments[selectedIndex.value].description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Doctors List Header
            Row(
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  t.specializedDoctors,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${t.experiencedMedicalProfessionalsIn} ${departments[selectedIndex.value].name}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),

            // Doctors List
            _DoctorsList(
              facilityId: facilityId,
              departmentId: departments[selectedIndex.value].id,
            ),
          ],
        );
      },
      error: (error, stackTrace) => _ErrorSection(error: error.toString()),
      loading: () => const _DepartmentsLoading(),
    );
  }
}

// 🏥 Doctors List Component
class _DoctorsList extends ConsumerWidget {
  final String facilityId;
  final String departmentId;

  const _DoctorsList({
    required this.facilityId,
    required this.departmentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(
          departmentDoctorsProvider((facilityId, departmentId)),
        )
        .when(
          data: (doctors) {
            if (doctors.isEmpty) {
              return const _NoDoctorsCard();
            }

            return ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: doctors.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  DoctorCard(doctor: doctors[index]),
            );
          },
          error: (error, stackTrace) => _ErrorSection(error: error.toString()),
          loading: () => const _DoctorsLoading(),
        );
  }
}

// 🏥 Loading and Error Components

class _NoDoctorsCard extends StatelessWidget {
  const _NoDoctorsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No Doctors Available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'There are no doctors in this department at the moment.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  final String error;
  const _ErrorSection({required this.error});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load data',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentsLoading extends StatelessWidget {
  const _DepartmentsLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 200,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) => Container(
              width: 120,
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DoctorsLoading extends StatelessWidget {
  const _DoctorsLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 3,
      itemBuilder: (context, index) => const ShimmerDoctorCard(),
    );
  }
}

// Keep your existing classes unchanged:
// FacilityUploads, FacilityScheduleSection, FacilityExceptionScheduleSection
// Keep your existing classes unchanged:
// FacilityUploads, FacilityScheduleSection, FacilityExceptionScheduleSection

class FacilityUploads extends ConsumerStatefulWidget {
  const FacilityUploads({super.key, required this.facilityId});
  final String facilityId;
  @override
  ConsumerState<FacilityUploads> createState() => _FacilityUploadsState();
}

class _FacilityUploadsState extends ConsumerState<FacilityUploads> {
  int _currentPage = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    final uploads = ref.watch(facilitiesUploadProvider(widget.facilityId));

    return uploads.when(
      data: (upload) {
        if (upload.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// IMPORTANT FIX:
            /// Wrap PageView in SizedBox   so height is determined by the CARD,
            /// not infinite page view.
            CarouselSlider.builder(
              carouselController: _carouselController,
              options: CarouselOptions(
                height: Config.screenHeight! * 0.42,
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                pauseAutoPlayOnTouch: true, // ✅ pauses on tap/hold
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentPage = index;
                  });
                },
              ),

              itemCount: upload.length,
              itemBuilder: (context, index, realIndex) {
                final item = upload[index];

                return GestureDetector(
                  onTap: () async {
                    await Get.dialog(
                      Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: const EdgeInsets.all(12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              /// FULLSCREEN IMAGE
                              Positioned.fill(
                                child: Image.network(
                                  item.getUploadUrl(),
                                  headers: const {
                                    'ngrok-skip-browser-warning': '1',
                                  },
                                  fit: BoxFit.contain,
                                ),
                              ),

                              /// DESCRIPTION AT BOTTOM
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  color: Colors.black.withOpacity(0.55),
                                  child: Text(
                                    item.description,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              /// TAP TO CLOSE LABEL (optional)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: IconButton(
                                  onPressed: () async => Get.back(),
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: 28,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      barrierColor: Colors.black.withOpacity(0.7),
                    );
                  },

                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        children: [
                          /// IMAGE
                          Positioned.fill(
                            child: Image.network(
                              item.getUploadUrl(),
                              headers: const {
                                'ngrok-skip-browser-warning': '1',
                              },
                              fit: BoxFit.contain,
                            ),
                          ),

                          /// GRADIENT FOR DESCRIPTION
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.black.withOpacity(0.65)
                                        : Colors.black.withOpacity(0.45),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          /// DESCRIPTION TEXT
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 14,
                            child: Text(
                              item.description,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black54,
                                        offset: Offset(0, 1),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            AnimatedSmoothIndicator(
              activeIndex: _currentPage,
              count: upload.length,
              effect: ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 3,
                activeDotColor: Theme.of(context).colorScheme.primary,
                dotColor: Colors.grey.shade400,
              ),
              onDotClicked: (index) {
                _carouselController.animateToPage(index);
              },
            ),
          ],
        );
      },

      loading: () => const ShimmerAppointmentCard(),
      error: (error, _) => Center(child: Text("Error: $error")),
    );
  }
}

class FacilityScheduleSection extends ConsumerWidget {
  final List<FacilitySchedule> schedule;

  const FacilityScheduleSection({super.key, required this.schedule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
  }
}

class FacilityExceptionScheduleSection extends ConsumerWidget {
  final List<FacilityExceptionSchedule> schedule;

  const FacilityExceptionScheduleSection({super.key, required this.schedule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

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
        Config.spaceMedium,

        const Text(
          '*note:Facility wont be openat this time',
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
  }
}
