import 'package:doctor_appointment_app/models/Facility/facility.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/utils/enums/specialitiez_facilities.dart';
import 'package:doctor_appointment_app/view/components/Common/cool_button.dart';
import 'package:doctor_appointment_app/view/components/Common/custom_appbar.dart';
import 'package:doctor_appointment_app/view/components/Common/error_pop_up.dart';
import 'package:doctor_appointment_app/view/components/Common/shimmer.dart';
import 'package:doctor_appointment_app/view/components/FacilitiesComponents/facility_card.dart';
import 'package:doctor_appointment_app/view_model/Facility/facilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';


class FacilitiesByTypePage extends ConsumerWidget {
  FacilitiesByTypePage({super.key});

  final String typeIndex = Get.arguments as String;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final AsyncValue<List<Facility>> facilityasync = ref.watch(
      facilitiesProvider(typeIndex),
    );
    final FacilitiesNotifier facilitiesAsyncNotifier = ref.watch(
      facilitiesProvider(typeIndex).notifier,
    );
    return Scaffold(
      appBar: CustomAppbar(
        appTitle: getFacilityTypesList(context).firstWhere((element) => element['key']==typeIndex,)['category'],
        icon:const  FaIcon(Icons.arrow_back_ios),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: RefreshIndicator.adaptive(
            onRefresh: () async {
              await facilitiesAsyncNotifier.refresh();
            },
            child: facilityasync.when(
              data: (facility) {
                return facility.isEmpty
                    ? const Center(child: Text('No facilities found'))
                    : NotificationListener<ScrollNotification>(
                        onNotification: (scrollInfo) {
                          if (scrollInfo.metrics.pixels >=
                                  scrollInfo.metrics.maxScrollExtent - 200 &&
                              !facilitiesAsyncNotifier.isLoadingMore &&
                              !facilitiesAsyncNotifier.isLastPage &&
                              facilitiesAsyncNotifier.loadMoreError == null) {
                            facilitiesAsyncNotifier.loadMore();
                          }
                          return false;
                        },
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmall = constraints.maxWidth < 360;
                            return ListView.builder(
                              itemCount:
                                  facility.length +
                                  (facilitiesAsyncNotifier.isLoadingMore ||
                                          facilitiesAsyncNotifier.isLastPage ||
                                          facilitiesAsyncNotifier
                                                  .loadMoreError !=
                                              null
                                      ? 1
                                      : 0),
                              itemBuilder: (context, index) {
                                if (index < facility.length) {
                                  return FacilityCard(facility: facility[index],);
                                }

                                // This is the extra "footer" item
                                if (facilitiesAsyncNotifier.isLoadingMore) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                if (facilitiesAsyncNotifier.loadMoreError !=
                                    null) {
                                  return CoolButton(
                                    isSmall: isSmall,
                                    onclick: () async =>
                                        await facilitiesAsyncNotifier
                                            .loadMore(),
                                    text: "اعادة المحاولة",
                                    icon: const Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                    ),
                                    alignment: Alignment.center,
                                  );
                                }
                                if (facilitiesAsyncNotifier.isLastPage) {
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
                itemCount: facilitiesAsyncNotifier.pageSize,
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
                    await facilitiesAsyncNotifier.refresh();
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
