import 'package:doctor_appointment_app/models/Doctor/doctor.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/utils/enums/specialitiez_facilities.dart';

import 'package:doctor_appointment_app/view/components/Common/cool_button.dart';
import 'package:doctor_appointment_app/view/components/Common/custom_appbar.dart';
import 'package:doctor_appointment_app/view/components/Common/error_pop_up.dart';
import 'package:doctor_appointment_app/view/components/Common/shimmer.dart';
import 'package:doctor_appointment_app/view/components/DoctorsComponents/doctor_card.dart';
import 'package:doctor_appointment_app/view_model/Doctor/doctors.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class DoctorsBySpecialityPage extends ConsumerWidget {
  DoctorsBySpecialityPage({super.key});

  final int specialityIndex = Get.arguments as int;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final AsyncValue<List<Doctor>> doctorsAsync = ref.watch(
      doctorProvider(specialityIndex),
    );
    final DoctorsNotifier doctorsAsyncNotifier = ref.watch(
      doctorProvider(specialityIndex).notifier,
    );
    return Scaffold(
      appBar: CustomAppbar(
        appTitle: getSpecialitiesList(context)[specialityIndex]['category'],
        icon: const FaIcon(Icons.arrow_back_ios),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: RefreshIndicator.adaptive(
            onRefresh: () async {
              await doctorsAsyncNotifier.refresh();
            },
            child: doctorsAsync.when(
              data: (doctors) {
                return doctors.isEmpty
                    ? const Center(child: Text('No doctors found'))
                    : NotificationListener<ScrollNotification>(
                        onNotification: (scrollInfo) {
                          if (scrollInfo.metrics.pixels >=
                                  scrollInfo.metrics.maxScrollExtent - 200 &&
                              !doctorsAsyncNotifier.isLoadingMore &&
                              !doctorsAsyncNotifier.isLastPage &&
                              doctorsAsyncNotifier.loadMoreError == null) {
                            doctorsAsyncNotifier.loadMore();
                          }
                          return false;
                        },
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmall = constraints.maxWidth < 360;
                            return ListView.builder(
                              itemCount:
                                  doctors.length +
                                  (doctorsAsyncNotifier.isLoadingMore ||
                                          doctorsAsyncNotifier.isLastPage ||
                                          doctorsAsyncNotifier.loadMoreError !=
                                              null
                                      ? 1
                                      : 0),
                              itemBuilder: (context, index) {
                                if (index < doctors.length) {
                                  return DoctorCard(doctor: doctors[index]);
                                }

                                // This is the extra "footer" item
                                if (doctorsAsyncNotifier.isLoadingMore) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                if (doctorsAsyncNotifier.loadMoreError !=
                                    null) {
                                  return CoolButton(
                                    isSmall: isSmall,
                                    onclick: () async =>
                                        await doctorsAsyncNotifier.loadMore(),
                                    text: "اعادة المحاولة",
                                    icon: const Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                    ),
                                    alignment: Alignment.center,
                                  );
                                }
                                if (doctorsAsyncNotifier.isLastPage) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10.0,
                                    ),
                                    child: Divider(
                                      color: Config.primaryColor,
                                      height: 2,
                                    ),
                                  );
                                }

                                return const SizedBox.shrink();
                              },
                            );
                          },
                        ),
                      );
              },
              loading: () => ListView.builder(
                itemCount: doctorsAsyncNotifier.pageSize,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, _) => const ShimmerDoctorCard(),
              ),
              error: (err, _) => Center(
                child: ErrorPopUp(
                  title: 'Something went wrong',
                  content: '',
                  buttonText: 'Retry',
                  onOk: () async {
                    await doctorsAsyncNotifier.clearFilters();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
