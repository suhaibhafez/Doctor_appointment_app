import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:doctor_appointment_app/utils/config.dart';

Color getBaseColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? const Color(0xFF1C2A2D)
      : const Color.fromARGB(255, 191, 232, 241);
}

Color getHighlightColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? const Color(0xFF26404A) : const Color(0xFFE6F0F3);
}

class ShimmerDoctorCard extends StatelessWidget {
  const ShimmerDoctorCard({super.key});

  @override
  Widget build(BuildContext context) {
    Config().init(context);

    // Detect current theme mode

    // Light theme: calm but visible
    final baseColor = getBaseColor(context);
    final highlightColor = getHighlightColor(context);

    return Container(
      padding: const EdgeInsets.all(10),
      height: Config.screenHeight! * 0.2,
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Card(
          elevation: 6,
          color: baseColor.withAlpha(
            120,
          ), // keep transparent for shimmer effect
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left side (image skeleton)
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Config.primaryColor, width: 2),
                  ),
                ),

                // Right side (text skeletons)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name placeholder
                        Container(
                          height: 18,

                          width: 150,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),

                        // Specialty placeholder
                        Container(
                          width: 120,
                          height: 14,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),

                        // Bottom row placeholders
                        Row(
                          spacing: 5,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: baseColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),

                            Container(
                              width: 16,
                              height: 14,
                              decoration: BoxDecoration(
                                color: baseColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),

                            Container(
                              width: 60,
                              height: 14,
                              decoration: BoxDecoration(
                                color: baseColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
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

class DoctorDetailsShimmer extends StatelessWidget {
  const DoctorDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Config().init(context);

    final baseColor = getBaseColor(context);
    final highlightColor = getHighlightColor(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile circle shimmer
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: const CircleAvatar(
              radius: 65.0,
              backgroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 25),

          // Doctor name placeholder
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: 180,
              height: 18,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Specialization placeholder
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: 120,
              height: 14,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Facility card shimmer
          const FacilityMapShimmer(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class FacilityMapShimmer extends StatelessWidget {
  const FacilityMapShimmer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = getBaseColor(context);
    final highlightColor = getHighlightColor(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class PatientDetailsShimmer extends StatelessWidget {
  const PatientDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final basecolor = getBaseColor(context);
    final highlight = getHighlightColor(context);

    return Shimmer.fromColors(
      baseColor: basecolor,
      highlightColor: highlight,
      child: Card(
        elevation: 6,
        color: basecolor.withAlpha(120),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: basecolor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Config.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          width: 150,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 14,
                          width: 100,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(height: 14, width: 60, color: basecolor),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsSectionShimmer extends StatelessWidget {
  const SettingsSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final base = getBaseColor(context);
    final highlight = getHighlightColor(context);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 20, width: 120, color: Colors.white),
              const SizedBox(height: 10),
              Container(height: 2, color: Colors.white),
              const SizedBox(height: 20),
              _buildSettingRow(),
              const SizedBox(height: 16),
              _buildSettingRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow() {
    return Row(
      children: [
        Container(width: 30, height: 30, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(
          child: Container(height: 40, color: Colors.white),
        ),
      ],
    );
  }
}

class ChronicDiseaseShimmer extends StatelessWidget {
  const ChronicDiseaseShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final base = getBaseColor(context);
    final highlight = getHighlightColor(context);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          5,
          (_) => Container(
            width: 90,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}

class AllergySectionShimmer extends StatelessWidget {
  const AllergySectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final base = getBaseColor(context);
    final highlight = getHighlightColor(context);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          5,
          (_) => Container(
            width: 90,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}

class ShimmerAppointmentCard extends StatelessWidget {
  const ShimmerAppointmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = getBaseColor(context);
    final highlightColor = getHighlightColor(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🕓 Date and status row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _shimmerBox(width: 100, height: 16, radius: 6),
                  _shimmerBox(width: 90, height: 30, radius: 10),
                ],
              ),
              const SizedBox(height: 10),

              // 🕒 Time range
              _shimmerBox(width: 120, height: 14, radius: 6),
              const SizedBox(height: 14),
              Divider(
                color: baseColor.withOpacity(0.5),
                thickness: 0.8,
              ),
              const SizedBox(height: 10),

              // 👨‍⚕️ Doctor Info
              Row(
                children: [
                  const Icon(Icons.medical_information_outlined, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _shimmerBox(
                      width: double.infinity,
                      height: 14,
                      radius: 6,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 🏥 Facility
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.local_hospital_outlined, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _shimmerBox(width: 140, height: 14, radius: 6),
                        const SizedBox(height: 6),
                        _shimmerBox(
                          width: double.infinity,
                          height: 14,
                          radius: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 🔘 Buttons placeholder
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: _shimmerBox(width: 80, height: 30, radius: 10),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _shimmerBox(width: 100, height: 30, radius: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class AppointmentDetailsShimmer extends StatelessWidget {
  const AppointmentDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final base = getBaseColor(context);
    final highlight = getHighlightColor(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Column(
        children: List.generate(
          3,
          (index) => _buildCardShimmer(base, highlight),
        ).expand((e) => [e, const SizedBox(height: 16)]).toList(),
      ),
    );
  }

  Widget _buildCardShimmer(base, highlight) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 18,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Info rows
              ...List.generate(
                4,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        height: 14,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 14,
                        width: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
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
  }
}
