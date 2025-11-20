
import 'package:carousel_slider/carousel_slider.dart';
import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:doctor_appointment_app/models/Facility/facility.dart';
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
        appTitle: AppLocalizations.of(context)!.doctorDetails,
        icon: const FaIcon(Icons.arrow_back_ios),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: facilityAsync.when(
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
                        // _AboutFacility(facility: data),
                        // Config.spaceSmall,
                        // FacilityMapPart(
                        //  lat: data.gpsLatitude!,
                        //  long: data.gpsLongitude!,
                        // ),
                        _AboutFacilityAndMap(facility: data),
                        Config.spaceMedium,
                        FacilityUploads(facilityId: facilityId),
                        Config.spaceMedium,

                        _DepartmentsPart(facilityId: data.id),
                      ],
                    ),
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

// 🏥 Departments + Doctors Section
class _DepartmentsPart extends HookConsumerWidget {
  final String facilityId;
  const _DepartmentsPart({required this.facilityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedIndex = useState(0);
    // Dummy data
    final departmentAsync = ref.watch(departmentsProvider(facilityId));

    return departmentAsync.when(
      data: (departments) {
        if (departments.isEmpty) {
          return const SizedBox();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Departments
            Text(
              'Departments',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: departments.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
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

            const SizedBox(height: 20),

            // 🔹 Doctors
            const SizedBox(height: 8),
            ref
                .watch(
                  departmentDoctorsProvider((
                    facilityId,
                    departments[selectedIndex.value].id,
                  )),
                )
                .when(
                  data: (doctors) => ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: doctors.length,
                    itemBuilder: (context, index) =>
                        DoctorCard(doctor: doctors[index]),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Text(error.toString()),
                  ),
                  loading: () => const ShimmerDoctorCard(),
                ),
          ],
        );
      },
      error: (error, stackTrace) => Center(
        child: Text(error.toString()),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}

// 🏥 About Facility + Map Combined Section
class _AboutFacilityAndMap extends StatelessWidget {
  final Facility facility;
  const _AboutFacilityAndMap({required this.facility});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              facility.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Address
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    facility.fullAddress!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // City + Country
            Row(
              children: [
                const Icon(Icons.public, size: 18),
                const SizedBox(width: 6),
                Text(
                  "${facility.city}, ${facility.country}",
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Type
            Row(
              children: [
                const Icon(Icons.local_hospital_outlined, size: 18),
                const SizedBox(width: 6),
                Text(
                  "Facility Type: ${facility.type}",
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🔹 MAP PART INSIDE SAME CARD
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
          return const NoAppointmentsCard();
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
