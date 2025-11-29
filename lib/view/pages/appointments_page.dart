import 'package:doctor_appointment_app/view_model/Appointment/appointments.dart';
import 'package:doctor_appointment_app/utils/config.dart';

import 'package:doctor_appointment_app/view/components/AppointmentsComponents/appointment_card.dart';
import 'package:doctor_appointment_app/view/components/AppointmentsComponents/appointment_filter_chips.dart';
import 'package:doctor_appointment_app/view/components/Common/cool_button.dart';
import 'package:doctor_appointment_app/view/components/Common/error_pop_up.dart';
import 'package:doctor_appointment_app/view/components/Common/shimmer.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppointmentPage extends ConsumerStatefulWidget {
  const AppointmentPage({super.key});

  @override
  ConsumerState<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends ConsumerState<AppointmentPage> {
   int? _selectedStatus; 
 

  @override
  Widget build(BuildContext context) {
    Config().init(context);
      _selectedStatus = ref.read(appointmentsProvider.notifier).status;
    final appointmentsAsyncValue = ref.watch(appointmentsProvider);
    final appointmentsNotifier = ref.watch(appointmentsProvider.notifier);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Config.spaceSmall,
            AppointmentFilterChips(
              selectedStatus: _selectedStatus,
              onChanged: (newStatus) async {
                _selectedStatus = newStatus;
                await appointmentsNotifier.updateStatus(_selectedStatus);
              },
            ),

            Config.spaceMedium,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: RefreshIndicator.adaptive(
                  onRefresh: () async {
                    await appointmentsNotifier.refresh();
                  },
                  child: appointmentsAsyncValue.when(
                    data: (appointments) {
                      return appointments.isEmpty
                          ? const Center(child: Text('No appointments found'))
                          : NotificationListener<ScrollNotification>(
                              onNotification: (scrollInfo) {
                                if (scrollInfo.metrics.pixels >=
                                        scrollInfo.metrics.maxScrollExtent -
                                            200 &&
                                    !appointmentsNotifier.isLoadingMore &&
                                    !appointmentsNotifier.isLastPage &&
                                    appointmentsNotifier.loadMoreError ==
                                        null) {
                                  appointmentsNotifier.loadMore();
                                }
                                return false;
                              },
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  final isSmall = constraints.maxWidth < 360;
                                  return ListView.builder(
                                    itemCount:
                                        appointments.length +
                                        (appointmentsNotifier.isLoadingMore ||
                                                appointmentsNotifier
                                                    .isLastPage ||
                                                appointmentsNotifier
                                                        .loadMoreError !=
                                                    null
                                            ? 1
                                            : 0),
                                    itemBuilder: (context, index) {
                                      if (index < appointments.length) {
                                        return Padding(
                                          padding:const EdgeInsetsGeometry.all(6),
                                          child: AppointmentCard(
                                            appointment: appointments[index],
                                          ),
                                        );
                                      }

                                      // This is the extra "footer" item
                                      if (appointmentsNotifier.isLoadingMore) {
                                        return const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(12),
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }
                                      if (appointmentsNotifier.loadMoreError !=
                                          null) {
                                        return CoolButton(
                                          isSmall: isSmall,
                                          onclick: () async =>
                                              await appointmentsNotifier
                                                  .loadMore(),
                                          text: "اعادة المحاولة",
                                          icon: const Icon(
                                            Icons.refresh,
                                            color: Colors.white,
                                          ),
                                          alignment: Alignment.center,
                                        );
                                      }
                                      if (appointmentsNotifier.isLastPage) {
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
                      itemCount: appointmentsNotifier.pageSize,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder:
                          (_, _) => //Shimmer Appointment Card
                              const ShimmerAppointmentCard(),
                    ),
                    error: (err, _) => Center(
                      child: ErrorPopUp(
                        title: 'Something went wrong',
                        content: '',
                        buttonText: 'Retry',
                        onOk: () async {
                          await appointmentsNotifier.refresh();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
