import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:flutter/material.dart';

class AppointmentFilterChips extends StatelessWidget {
  final int? selectedStatus;
  final ValueChanged<int?> onChanged;

  const AppointmentFilterChips({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    final textColor = isDark ? Config.textLight : Config.textDark;

    // Define filter options
    final filters = <Map<String, dynamic>>[
      {
        'label': AppLocalizations.of(context)!.appointmentStatusAll,
        'value': null,
      },
      {
        'label': AppLocalizations.of(context)!.appointmentStatusPending,
        'value': 1,
      },
      {
        'label': AppLocalizations.of(context)!.appointmentStatusConfirmed,
        'value': 2,
      },
      {
        'label': AppLocalizations.of(context)!.appointmentStatusCompleted,
        'value': 3,
      },
      {
        'label': AppLocalizations.of(context)!.appointmentStatusCancelled,
        'value': 4,
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),

      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = selectedStatus == filter['value'];
            return Padding(
              padding: const EdgeInsets.all(4),
              child: ChoiceChip(
                label: Text(
                  filter['label'],
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : textColor),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => onChanged(filter['value']),
                selectedColor: primary,
                shadowColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? primary : Colors.grey.shade400,
                    width: 1.2,
                  ),
                ),
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 2,
                ),
                elevation: isSelected ? 2 : 0,
                // pressElevation: 0,
                showCheckmark: false,
                selectedShadowColor: primary,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
