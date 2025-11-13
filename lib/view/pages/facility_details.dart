import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:doctor_appointment_app/models/Facility/facility.dart';
import 'package:doctor_appointment_app/view_model/Facility/departments.dart';
import 'package:doctor_appointment_app/view_model/Facility/doctors_in_department.dart';
import 'package:doctor_appointment_app/view_model/Facility/facility_by_id.dart';
import 'package:doctor_appointment_app/utils/config.dart';

import 'package:doctor_appointment_app/view/components/Common/custom_appbar.dart';
import 'package:doctor_appointment_app/view/components/DoctorsComponents/doctor_card.dart';
import 'package:doctor_appointment_app/view/components/FacilitiesComponents/facility_map_part.dart';
import 'package:doctor_appointment_app/view/components/Common/loading.dart';
import 'package:doctor_appointment_app/view/components/Common/shimmer.dart';
import 'package:doctor_appointment_app/view/pages/search_page.dart';
import 'package:flutter/material.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/route_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
                        _AboutFacility(facility: data),
                        Config.spaceSmall,
                        FacilityMapPart(
                         lat: data.gpsLatitude!,
                         long: data.gpsLongitude!,
                        ),
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
                  loading: () => const Loading(),
                ),
          ],
        );
      },
      error: (error, stackTrace) => Center(
        child: Text(error.toString()),
      ),
      loading: () => const Loading(),
    );
  }
}

// 🏥 About Facility Section
class _AboutFacility extends StatelessWidget {
  final Facility facility;
  const _AboutFacility({required this.facility});

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
            Text(
              facility.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
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
          ],
        ),
      ),
    );
  }
}
