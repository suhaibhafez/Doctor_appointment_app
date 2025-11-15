
import 'package:doctor_appointment_app/models/Appointment/appointment.dart';
import 'package:doctor_appointment_app/routes/routes.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/utils/enums/specialitiez_facilities.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppointmentCard extends StatelessWidget {
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
          child: const Text("Reschedule"),
        ),
      ];
    } else if (isCompletedOrCancelled) {
      return [
        ElevatedButton(
          onPressed: () {},
          style: buttonStyle,
          child: const Text("Rebook"),
        ),
      ];
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  style: theme.textTheme.headlineSmall!.copyWith(fontSize: 18),
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
                    "${appointment.facility.name}\n${appointment.facility.fullAddress}",
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
            Align(
              alignment: AlignmentGeometry.centerRight,
              child: TextButton.icon(
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
