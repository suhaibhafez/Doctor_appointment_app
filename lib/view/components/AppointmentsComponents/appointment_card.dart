import 'package:doctor_appointment_app/models/Appointment/appointment.dart';
import 'package:doctor_appointment_app/models/Appointment/review.dart';
import 'package:doctor_appointment_app/routes/routes.dart';
import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:doctor_appointment_app/services/patient_services.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/utils/enums/specialitiez_facilities.dart';
import 'package:doctor_appointment_app/view/components/Common/cool_button.dart';
import 'package:doctor_appointment_app/view/components/Common/error_pop_up.dart';
import 'package:doctor_appointment_app/view/components/Common/loading.dart';
import 'package:doctor_appointment_app/view_model/Appointment/review.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class AppointmentCard extends ConsumerWidget {
  final Appointment appointment;

  const AppointmentCard({
    super.key,
    required this.appointment,
  });

  // 🟩 Helper for time range like 8:00 - 8:30
  String _formatTimeRange(String startTime, int durationMinutes) {
    final start = TimeOfDay(
      hour: int.parse(startTime.split(":")[0]),
      minute: int.parse(startTime.split(":")[1]),
    );
    final end = TimeOfDay(
      hour: (start.hour * 60 + start.minute + durationMinutes) ~/ 60,
      minute: (start.minute + durationMinutes) % 60,
    );
    String fmt(TimeOfDay t) =>
        "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
    return "${fmt(start)} - ${fmt(end)}";
  }

  // 🟨 Status color

  // 🟦 Status badge

  // 🟧 Action buttons depending on status
  List<Widget> _actionButtons(BuildContext context) {
    final isPendingOrConfirmed = [
      "pending",
      "confirmed",
    ].contains(appointment.status.toLowerCase());
    final isCompletedOrCancelled = [
      "completed",
      "cancelled",
    ].contains(appointment.status.toLowerCase());

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
    );

    if (isPendingOrConfirmed) {
      return [
        ElevatedButton(
          onPressed: () {},
          style: buttonStyle.copyWith(
            backgroundColor: WidgetStatePropertyAll(
              Theme.of(context).colorScheme.error,
            ),
          ),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {},
          style: buttonStyle,
          child: const Text(
            "Reschedule",
          ),
        ),
      ];
    } else if (isCompletedOrCancelled) {
      return [
        ElevatedButton(
          onPressed: () async{
              await Get.toNamed(
              Sroutes.bookingPage,
              parameters: {
                'docId': appointment.doctor.id,
                'facId': appointment.facility.id,
              },
            );
          },
          style: buttonStyle,
          child: const Text("Rebook"),
        ),
      ];
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final date =
        "${appointment.scheduledDate.year}-${appointment.scheduledDate.month.toString().padLeft(2, '0')}-${appointment.scheduledDate.day.toString().padLeft(2, '0')}";
    final timeRange = _formatTimeRange(
      appointment.scheduledTime,
      appointment.durationMinutes,
    );

    final speciality = getLocalizedSpe(
      appointment.doctor.specialization,
      context,
      false,
    );

    return Card(
      elevation: 5,

      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🕓 Date & Status row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: theme.textTheme.headlineSmall!.copyWith(
                    fontSize: 18,
                  ),
                ),
                statusChip(appointment.status, context),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              timeRange,
              style: theme.textTheme.bodyLarge!.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),

            const Divider(
              height: 20,
              color: Config.primaryColor,
            ),

            // 👨‍⚕️ Doctor Info
            Row(
              children: [
                Icon(
                  Icons.medical_information_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${appointment.doctor.firstName} ${appointment.doctor.lastName} • $speciality",
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 🏥 Facility
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.local_hospital_outlined,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appointment.facility.name,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 🔘 Actions
            if (_actionButtons(context).isNotEmpty)
              Row(
                children: _actionButtons(context)
                    .map(
                      (btn) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: btn,
                        ),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (appointment.status == 'Completed')
                  TextButton.icon(
                    onPressed: () async {
                      await Get.dialog(
                        ReviewDialog(appointmentId: appointment.id),
                        barrierDismissible: false,
                      );
                    },
                    label: const Text('Review'),
                    icon: const Icon(
                      Icons.star,
                      color: Colors.amberAccent,
                    ),
                  ),
                if (appointment.status != 'Completed') const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    await Get.toNamed(
                      '${Sroutes.appointmentDetails}/${appointment.id}',
                    );
                  },
                  label: const Text('More info'),
                  icon: const Icon(Icons.info_outline),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget statusChip(String status, BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: statusColor(status, context).withOpacity(0.15),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: statusColor(status, context), width: 1),
    ),
    child: Text(
      status,
      style: TextStyle(
        color: statusColor(status, context),
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Color statusColor(String status, BuildContext context) {
  final theme = Theme.of(context);
  switch (status.toLowerCase()) {
    case "pending":
      return Colors.amber.shade700;
    case "confirmed":
      return Config.primaryColor;
    case "completed":
      return Colors.green.shade600;
    case "cancelled":
      return theme.colorScheme.error;
    default:
      return Colors.grey;
  }
}

class ReviewDialog extends ConsumerWidget {
  final String appointmentId;

  const ReviewDialog({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewAsync = ref.watch(reviewProvider(appointmentId));

    return reviewAsync.when(
      loading: () => const Loading(),

      error: (err, st) =>
          ErrorPopUp(title: 'Something went wrong', content: err.toString()),

      data: (data) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: data == null
              ? _RatingForm(appointmentId: appointmentId)
              : _ExistingReviewDisplay(review: data),
        ),
      ),
    );
  }
}

class _ExistingReviewDisplay extends StatelessWidget {
  final Review review;

  const _ExistingReviewDisplay({required this.review});

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Your Review",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Config.spaceSmall,

        // ⭐ Rating
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (i) => Icon(
              i < review.rating ? Icons.star : Icons.star_border,
              color: Config.accentColor,
              size: 42,
            ),
          ),
        ),
        Config.spaceSmall,

        // 💬 Comment
        if (review.comment != null)
          Container(
            constraints: const BoxConstraints(
              maxHeight: 150, // dialog-safe height
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Scrollbar(
              thumbVisibility: true,
              radius: const Radius.circular(12),
              child: SingleChildScrollView(
                child: Text(
                  review.comment!,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    height: 1.4,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          ),

        Config.spaceSmall,
        SizedBox(
          width: double.infinity,
          child: CoolButton(
            text: 'Close',
            isSmall: Config.screenWidth! < 360,
            onclick: () => Get.back(),
          ),
        ),
      ],
    );
  }
}

class _RatingForm extends ConsumerStatefulWidget {
  final String appointmentId;

  const _RatingForm({required this.appointmentId});

  @override
  ConsumerState<_RatingForm> createState() => _RatingFormState();
}

class _RatingFormState extends ConsumerState<_RatingForm> {
  int rating = 0;
  final TextEditingController commentCtrl = TextEditingController();
  bool submitting = false;

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Rate Appointment",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Config.spaceSmall,

          // ⭐ Rating stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => GestureDetector(
                onTap: () => setState(() => rating = i + 1),
                child: Icon(
                  i < rating ? Icons.star : Icons.star_border,
                  size: 42,
                  color: Config.accentColor,
                ),
              ),
            ),
          ),
          Config.spaceSmall,

          // 💬 Comment
          TextField(
            controller: commentCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Comment (optional)",
              alignLabelWithHint: true,
              labelStyle: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),

          Config.spaceSmall,

          submitting
              ? const CircularProgressIndicator()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CoolButton(
                      isSmall: Config.screenWidth! < 360,
                      onclick: () async {
                        FocusScope.of(context).unfocus();

                        if (Get.isSnackbarOpen) {
                          // await Get.closeCurrentSnackbar();
                          Get.back();
                        }
                        if (Get.isDialogOpen == true) {
                          Get.back(); // close the dialog
                        }
                      },
                      text: 'Cancel',
                      backgroundColor: Colors.redAccent,
                    ),

                    CoolButton(
                      onclick: () async {
                        FocusScope.of(context).unfocus();

                        if (rating == 0) {
                          if (Get.isSnackbarOpen) {
                            await Get.closeCurrentSnackbar();
                          }
                          Get.snackbar(
                            "Error",
                            "Please select a rating.",

                            colorText: Colors.white,
                            backgroundColor: Colors.redAccent,
                          );
                          return;
                        }

                        setState(() => submitting = true);

                        try {
                          final token = LocalStorageService.getToken!;
                          await PatientService.reviewAnAppointmnet(
                            apId: widget.appointmentId,
                            rating: rating,
                            comment: commentCtrl.text.trim().isEmpty
                                ? null
                                : commentCtrl.text.trim(),
                            ref: ref,
                            token: token,
                          );

                          ref.invalidate(reviewProvider(widget.appointmentId));

                          Get.back();

                          if (Get.isSnackbarOpen) {
                            await Get.closeCurrentSnackbar();
                          }
                          Get.snackbar(
                            "Success",
                            "Review submitted",
                            backgroundColor: Config.accentColor,
                            colorText: Colors.white,
                          );
                        } catch (e) {
                          if (Get.isSnackbarOpen) {
                            await Get.closeCurrentSnackbar();
                          }
                          Get.snackbar(
                            "Error",
                            e.toString(),
                            backgroundColor: Config.errorColor,
                            colorText: Colors.white,
                          );
                        } finally {
                          setState(() => submitting = false);
                        }
                      },
                      text: 'Submit',
                      isSmall: Config.screenWidth! < 360,
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
