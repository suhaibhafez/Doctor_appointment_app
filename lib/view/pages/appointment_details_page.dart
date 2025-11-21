import 'package:doctor_appointment_app/models/Appointment/appointment_details.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/utils/enums/specialitiez_facilities.dart';

import 'package:doctor_appointment_app/view/components/Common/custom_appbar.dart';
import 'package:doctor_appointment_app/view/components/Common/error_pop_up.dart';

import 'package:doctor_appointment_app/view/components/Common/shimmer.dart';
import 'package:doctor_appointment_app/view/components/FacilitiesComponents/facility_map_part.dart';
import 'package:doctor_appointment_app/view_model/Appointment/appointment_by_id.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AppointmentDetailsPage extends ConsumerWidget {
  AppointmentDetailsPage({super.key})
    : appointmentId = Get.parameters['id'] ?? '';
  final String appointmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAppointment = ref.watch(appointmentByIdProvider(appointmentId));
    Config().init(context);
    if (appointmentId.isEmpty) {
      return const Scaffold(
        appBar: CustomAppbar(
          appTitle: 'Appointment details',
          icon: FaIcon(Icons.arrow_back_ios),
        ),
        body: Center(
          child: Text('Invalid appointmnet ID'),
        ),
      );
    }
    return Scaffold(
      appBar: const CustomAppbar(
        appTitle: 'Appointment details',
        icon: FaIcon(Icons.arrow_back_ios),
      ),
      body: asyncAppointment.when(
        data: (appointment) {
          return _AppointmentDetailsBody(appointment); //page;
        },
        error: (e, st) => Center(
          child: ErrorPopUp(
            title: 'Something went wrong',
            content: e.toString(),
          ),
        ),
        loading: () => const AppointmentDetailsShimmer(),
      ),
    );
  }
}

class _AppointmentDetailsBody extends StatelessWidget {
  final AppointmentDetails appointment;
  const _AppointmentDetailsBody(this.appointment);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    Color accent = isDark ? Config.accentColor : Config.primaryColor;

    Color labelColor = isDark ? Colors.white70 : Colors.black87;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionCard(
            icon: FontAwesomeIcons.solidCalendarCheck,
            title: "Appointment Info",
            children: [
              _InfoRow('Status', appointment.status),

              _InfoRow("Date", _formatDate(appointment.scheduledDate)),
              _InfoRow("Time", appointment.scheduledTime),
              _InfoRow("Duration", "${appointment.durationMinutes} min"),
              _InfoRow("Booked On", _formatDate(appointment.bookingDate)),
              if (appointment.checkInTime != null)
                _InfoRow("Check-in", _formatDateTime(appointment.checkInTime!)),
              if (appointment.checkOutTime != null)
                _InfoRow(
                  "Check-out",
                  _formatDateTime(appointment.checkOutTime!),
                ),
            ],
          ),
          Config.spaceSmall,
          _SectionCard(
            icon: Icons.person,
            title: "Patient",
            children: [
              _InfoRow("Name", appointment.patient.fullName!),
              _InfoRow("National ID", appointment.patient.nationalId),
              _InfoRow("Gender", appointment.patient.gender!),
            ],
          ),
          Config.spaceSmall,
          _SectionCard(
            icon: Icons.medical_information_outlined,
            title: "Doctor",
            children: [
              _InfoRow(
                "Name",
                '${appointment.doctor.firstName} ${appointment.doctor.lastName}',
              ),
              _InfoRow(
                "Specialty",
                getLocalizedSpe(
                  appointment.doctor.specialization,
                  context,
                  false,
                ),
              ),
              // _InfoRow("Email", appointment.doctor.email),
            ],
          ),
          Config.spaceSmall,
          _SectionCard(
            icon: Icons.apartment,
            title: "Facility",
            children: [
              _InfoRow('Name', appointment.facility.name),
              _InfoRow('State', appointment.facility.state!),
              _InfoRow('Street', appointment.facility.street!),

              FacilityMapPart(
                lat: appointment.facility.gpsLatitude!,
                long: appointment.facility.gpsLongitude!,
              ),
            ],
          ),
          if (appointment.billing != null) ...[
            Config.spaceSmall,
            _SectionCard(
              icon: Icons.receipt_long,
              title: "Billing",
              children: [
                _InfoRow("Status", appointment.billing!.status),
                _InfoRow("Total", "${appointment.billing!.totalAmount} USD"),
                _InfoRow(
                  "Issued",
                  _formatDate(appointment.billing!.dateIssued),
                ),
                if (appointment.billing!.paidAmount != null)
                  _InfoRow("Paid", "${appointment.billing!.paidAmount} USD"),
                if (appointment.billing!.paymentDate != null)
                  _InfoRow(
                    "Paid On",
                    _formatDate(appointment.billing!.paymentDate!),
                  ),
              ],
            ),
          ],
          if (appointment.prescriptions != null &&
              appointment.prescriptions!.isNotEmpty) ...[
            Config.spaceSmall,
            _SectionCard(
              icon: Icons.medical_services_outlined,
              title: "Prescriptions",
              children: appointment.prescriptions!.map((p) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Config.surfaceDark.withOpacity(0.6)
                        : Config.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accent.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Issued: ${p.dateIssued.day}/${p.dateIssued.month}/${p.dateIssued.year}",
                        style: textTheme.bodySmall?.copyWith(
                          color: labelColor.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Medications: ",
                              style: textTheme.bodyMedium?.copyWith(
                                color: labelColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: p.medicationList,
                              style: textTheme.bodyMedium?.copyWith(
                                color: labelColor,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Dosage: ",
                              style: textTheme.bodySmall?.copyWith(
                                color: labelColor.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: p.dosageInstructions,
                              style: textTheme.bodySmall?.copyWith(
                                color: labelColor.withOpacity(0.8),
                                fontWeight: FontWeight.normal,
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
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => "${date.day}/${date.month}/${date.year}";

  String _formatDateTime(DateTime date) =>
      "${_formatDate(date)} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall!.copyWith(fontSize: 18),
                ),
              ],
            ),
            const Divider(
              height: 20,
              color: Config.primaryColor,
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,

              style: theme.textTheme.bodyMedium,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
