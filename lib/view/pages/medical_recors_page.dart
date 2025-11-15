import 'package:doctor_appointment_app/models/Patient/medical_record.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/view/components/Common/custom_appbar.dart';
import 'package:doctor_appointment_app/view/components/Common/error_pop_up.dart';
import 'package:doctor_appointment_app/view/components/Common/shimmer.dart';
import 'package:doctor_appointment_app/view_model/Patient/medical_records.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class MedicalRecorsPage extends ConsumerWidget {
  const MedicalRecorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Config().init(context);
    final medicalRecordsState = ref.watch(medicalRecordsProvider);

    return Scaffold(
      appBar: const CustomAppbar(
        appTitle: 'Medical Records',
        icon: FaIcon(Icons.arrow_back_ios),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),

          child: medicalRecordsState.when(
            data: (records) => ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return MedicalRecordCard(record: record);
              },
            ),
            error: (error, stackTrace) => ErrorPopUp(
              title: 'Something went wrong',
              content: error.toString(),
            ),
            loading: () => const MedicalRecordShimmer(),
          ),
        ),
      ),
    );
  }
}

class MedicalRecordCard extends StatelessWidget {
  final MedicalRecord record;

  const MedicalRecordCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    Color accent = Config.primaryColor;
    Color surface = theme.cardTheme.color ?? Colors.white;
    Color labelColor = isDark ? Colors.white70 : Colors.black87;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Doctor & Facility
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: accent.withOpacity(0.15),
                  child: Icon(
                    Icons.local_hospital_rounded,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.doctorFullName,
                        style: textTheme.titleMedium?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        record.facilityName,
                        style: textTheme.bodyMedium?.copyWith(
                          color: labelColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${record.recordDate.day}/${record.recordDate.month}/${record.recordDate.year}",
                  style: textTheme.bodySmall?.copyWith(
                    color: labelColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(
              color: Config.primaryColor,
              height: 1.2,
            ),

            // 🔹 Diagnosis
            _section(
              context,
              title: "Diagnosis",

              content: record.diagnosis,
            ),

            // 🔹 Treatment Notes
            _section(
              context,
              title: "Treatment Notes",

              content: record.treatmentNotes,
            ),

            // 🔹 Follow-up
            _section(
              context,
              title: "Follow-Up Instructions",

              content: record.followUpInstructions,
            ),

            const SizedBox(height: 6),

            // 🔹 Scheduled Date & Time
            _section(
              context,
              title: 'Appointment',
              content:
                  " ${record.scheduledDate.day}/${record.scheduledDate.month}/${record.scheduledDate.year} at ${record.scheduledTime}",
            ),

            const SizedBox(height: 14),

            // 🔹 Prescriptions
            if (record.prescriptions.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Prescriptions",
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...record.prescriptions.map((p) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 6),
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
                          Text(
                            "Medications: ${p.medicationList}",
                            style: textTheme.bodyMedium?.copyWith(
                              color: labelColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Dosage: ${p.dosageInstructions}",
                            style: textTheme.bodySmall?.copyWith(
                              color: labelColor.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,

    required String content,
  }) {
    final theme = Theme.of(context);

    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Config.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            content.isNotEmpty ? content : "No data provided.",
            style: TextStyle(color: textColor.withOpacity(0.9), height: 1.4),
          ),
        ],
      ),
    );
  }
}

class MedicalRecordShimmer extends StatelessWidget {
  const MedicalRecordShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = getBaseColor(context);
    final highlightColor = getHighlightColor(context);

    return ListView.builder(
      itemCount: 3, // show 3 shimmer placeholders
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor.withOpacity(0.4),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Header row
                  Row(
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: baseColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _shimmerLine(width: 120),
                            const SizedBox(height: 6),
                            _shimmerLine(width: 80),
                          ],
                        ),
                      ),
                      _shimmerLine(width: 60, height: 12),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 🔹 Body sections
                  _shimmerSection(),
                  _shimmerSection(),
                  _shimmerSection(),

                  const SizedBox(height: 10),

                  // 🔹 Prescription list
                  _shimmerLine(width: 100, height: 14),
                  const SizedBox(height: 10),

                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shimmerLine(width: 130),
                        const SizedBox(height: 8),
                        _shimmerLine(width: 180),
                        const SizedBox(height: 4),
                        _shimmerLine(width: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _shimmerLine({double width = double.infinity, double height = 14}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _shimmerSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerLine(width: 100, height: 14),
          const SizedBox(height: 8),
          _shimmerLine(width: double.infinity, height: 12),
          const SizedBox(height: 6),
          _shimmerLine(width: double.infinity, height: 12),
        ],
      ),
    );
  }
}
