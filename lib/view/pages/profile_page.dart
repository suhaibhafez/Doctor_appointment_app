import "package:doctor_appointment_app/l10n/app_localizations.dart";
import "package:doctor_appointment_app/models/Patient/allergy.dart";
import "package:doctor_appointment_app/models/Patient/chronic_disease.dart";
import "package:doctor_appointment_app/view_model/Patient/allergy.dart";
import "package:doctor_appointment_app/view_model/Patient/chronic_disease.dart";

import "package:doctor_appointment_app/view_model/Patient/patient.dart";
import "package:doctor_appointment_app/view_model/settings.dart";
import "package:doctor_appointment_app/routes/routes.dart";
import "package:doctor_appointment_app/utils/config.dart";
import "package:doctor_appointment_app/utils/enums/allergies.dart";
import "package:doctor_appointment_app/utils/enums/chronic_diseases.dart";
import "package:doctor_appointment_app/view/components/Common/cool_button.dart";
import "package:doctor_appointment_app/view/components/Common/error_pop_up.dart";
import "package:doctor_appointment_app/view/components/Common/shimmer.dart";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";

import "package:get/route_manager.dart";
import "package:intl/intl.dart";

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  void handleAsyncState<T>(
    AsyncValue<T> next, {
    required String errorMessage,
    required VoidCallback? onData,
  }) async {
    // if (next.isLoading) {
    //   if (!Get.isDialogOpen!) {
    //     await Get.dialog(const Loading(), barrierDismissible: false);
    //   }
    // } else {
    //   if (Get.isDialogOpen!) Get.back();
    // }

    next.whenOrNull(
      error: (error, _) async {
        await Get.dialog(
          ErrorPopUp(title: errorMessage, content: ''),
        );
      },
      data: (_) => onData?.call(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(patientNotifier, (previous, next) async {
      handleAsyncState(
        next,
        errorMessage: 'Something went wrong fetching patient data',
        onData: () async {
          if (Get.isDialogOpen!) Get.back();
          if (next.value == null) {
            await Get.offAllNamed(Sroutes.auth);
          }
        },
      );
    });

    final theme = Theme.of(context);
    Config().init(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(patientNotifier);
            ref.invalidate(chronicDiseaseProvider);
            ref.invalidate(allergiesProvider);
            ref.invalidate(settingsProvider);
          },
          child: const SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PatientDetailsSection(),
                SizedBox(height: 10),
                SettingsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//
// 🩺 1️⃣ Patient Details Section
//
class PatientDetailsSection extends ConsumerWidget {
  const PatientDetailsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(patientNotifier);

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 360;
        return Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: theme.colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Row: profile picture + info ---
                patientAsync.when(
                  data: (patient) {
                    if (patient == null) {
                      return const Center(child: Text('No patient data found'));
                    }
                    return Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 55,
                            foregroundImage: AssetImage('assets/profile1.jpg'),
                            backgroundColor: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${patient.firstName} ${patient.lastName}',
                                style: textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),

                              Text(
                                patient.nationalId,
                                style: textTheme.bodyMedium!.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.primary,
                                ),
                              ),

                              const SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'yyyy-MM-dd',
                                ).format(patient.dateOfBirth!),
                                style: textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                patient.gender!,
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const PatientDetailsShimmer(),
                  error: (_, __) => const Center(child: Text('Error')),
                ),

                const SizedBox(height: 24),

                const Divider(
                  color: Config.primaryColor,
                  height: 2,
                ),
                const SizedBox(height: 25),
                // --- Chronic diseases & allergies (dummy chips) ---
                Text(
                  'Chronic Diseases',
                  style: textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                const ChronicDiseaseSection(),
                const SizedBox(height: 16),

                Text(
                  'Allergies',
                  style: textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                const AllergySection(),

                const SizedBox(height: 25),
                const Divider(
                  color: Config.primaryColor,
                  height: 2,
                ),
                const SizedBox(height: 25),
                // --- Buttons: medical record + logout ---
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: CoolButton(
                        isSmall: isSmall,
                        onclick: () async {
                          await Get.toNamed(Sroutes.medicalRecordPage);
                        },
                        text: "Medical History",
                        icon: const Icon(Icons.history),
                        alignment: Alignment.center,
                      ),
                    ),
                    Expanded(
                      child: CoolButton(
                        isSmall: isSmall,
                        onclick: () async {
                          await Get.toNamed(Sroutes.billingPage);
                        },
                        icon: const Icon(
                          Icons.receipt_long,
                        ),
                        text: 'Billing',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

//
// ⚙️ 2️⃣ Settings Section
//
class SettingsSection extends ConsumerWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge!.color;

    return settingsAsync.when(
      loading: () => const SettingsSectionShimmer(),
      error: (err, st) => Center(
        child: Text(
          'Error loading settings',
          style: TextStyle(color: theme.colorScheme.error),
        ),
      ),
      data: (settings) {
        return Card(
          color: theme.colorScheme.surface,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.settings,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const Divider(
                  color: Config.primaryColor,
                  height: 2,
                ),

                const SizedBox(height: 10),

                // Theme toggle
                _settingRow(
                  context,
                  icon: Icons.brightness_6,
                  child: ToggleButtons(
                    borderRadius: BorderRadius.circular(12),
                    borderColor: Colors.grey,
                    selectedBorderColor: theme.colorScheme.primary,
                    color: Colors.grey.shade700,
                    selectedColor: Colors.white,
                    fillColor: theme.colorScheme.primary,
                    constraints: const BoxConstraints(
                      minHeight: 40,
                      minWidth: 70,
                    ),
                    isSelected: [
                      settings['theme'] == ThemeMode.dark,
                      settings['theme'] == ThemeMode.system,
                      settings['theme'] == ThemeMode.light,
                    ],
                    onPressed: (index) {
                      final notifier = ref.read(settingsProvider.notifier);
                      switch (index) {
                        case 0:
                          notifier.setTheme('dark');
                          break;
                        case 1:
                          notifier.setTheme('system');
                          break;
                        case 2:
                          notifier.setTheme('light');
                          break;
                      }
                    },
                    children: [
                      const Icon(FontAwesomeIcons.moon, size: 18),
                      Text(AppLocalizations.of(context)!.system),
                      const Icon(FontAwesomeIcons.sun, size: 18),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Language toggle
                _settingRow(
                  context,
                  icon: FontAwesomeIcons.language,
                  child: ToggleButtons(
                    borderRadius: BorderRadius.circular(12),
                    borderColor: Colors.grey,
                    selectedBorderColor: theme.colorScheme.primary,
                    color: Colors.grey.shade700,
                    selectedColor: Colors.white,
                    fillColor: theme.colorScheme.primary,
                    constraints: const BoxConstraints(
                      minHeight: 40,
                      minWidth: 105,
                    ),
                    isSelected: [
                      settings['lang'] == 'en',
                      settings['lang'] == 'ar',
                    ],
                    onPressed: (index) async {
                      final notifier = ref.read(settingsProvider.notifier);
                      if (index == 0) {
                        await notifier.setLanguage('en');
                        await Get.updateLocale(const Locale('en'));
                      } else {
                        await notifier.setLanguage('ar');
                        await Get.updateLocale(const Locale('ar'));
                      }
                    },
                    children: const [
                      Text('EN', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('AR', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: CoolButton(
                    isSmall: false,
                    onclick: () async {
                      await ref.read(patientNotifier.notifier).logout();
                    },
                    icon: const Icon(
                      Icons.logout_outlined,
                    ),
                    text: AppLocalizations.of(context)!.logout,
                    backgroundColor: theme.colorScheme.surface.withAlpha(255),
                    forGroundColor: theme.colorScheme.error,
                    borderColor: theme.colorScheme.error.withAlpha(110),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _settingRow(
    BuildContext context, {
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        spacing: 10,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class ChronicDiseaseSection extends ConsumerWidget {
  const ChronicDiseaseSection({super.key});
  Future<void> showAddChronicDiseaseSheet(
    BuildContext context,
    WidgetRef ref,
    List<ChronicDisease> selectedDiseases,
  ) async {
    final theme = Theme.of(context);

    // Get all enum values except "None"
    final allDiseases = ChronicDiseaseType.values
        .where((e) => e != ChronicDiseaseType.None)
        .toList();
    final isSmall = MediaQuery.of(context).size.width < 360;
    // Exclude already selected
    final selectedNames = selectedDiseases.map((d) => d.name).toSet();
    final availableDiseases = allDiseases
        .where((e) => !selectedNames.contains(e.name))
        .toList();

    // Controller for selected options
    final ValueNotifier<Set<ChronicDiseaseType>> selectedSet = ValueNotifier(
      <ChronicDiseaseType>{},
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 25,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Top grab handle ---
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text(
                'Add Chronic Diseases',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              if (availableDiseases.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Text(
                      'All diseases already added ✅',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                Flexible(
                  child: ValueListenableBuilder<Set<ChronicDiseaseType>>(
                    valueListenable: selectedSet,
                    builder: (context, selected, _) {
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: availableDiseases.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 2,
                          color: Config.primaryColor,
                        ),
                        itemBuilder: (context, index) {
                          final disease = availableDiseases[index];
                          final isSelected = selected.contains(disease);
                          return ListTile(
                            leading: const Icon(
                              Icons.health_and_safety,
                              color: Color(0xFF53C1B0),
                            ),
                            title: Text(
                              disease.name,
                              style: theme.textTheme.bodyLarge,
                            ),
                            trailing: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(
                                    scale: anim,
                                    child: child,
                                  ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check_circle,
                                      key: const ValueKey('checked'),
                                      color: theme.colorScheme.primary,
                                    )
                                  : Icon(
                                      Icons.circle_outlined,
                                      key: const ValueKey('unchecked'),
                                      color: theme.colorScheme.primary,
                                    ),
                            ),
                            onTap: () {
                              final newSet = {...selected};
                              if (isSelected) {
                                newSet.remove(disease);
                              } else {
                                newSet.add(disease);
                              }
                              selectedSet.value = newSet;
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),

              // --- Action buttons ---
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: CoolButton(
                      isSmall: isSmall,
                      onclick: () {
                        Get.back();
                      },

                      text: 'Cancel',
                      backgroundColor: theme.colorScheme.surface,
                      forGroundColor: theme.colorScheme.error,
                      borderColor: theme.colorScheme.error.withAlpha(110),
                    ),
                  ),

                  Expanded(
                    child: ValueListenableBuilder<Set<ChronicDiseaseType>>(
                      valueListenable: selectedSet,
                      builder: (context, selected, _) {
                        return CoolButton(
                          isSmall: isSmall,
                          onclick: selected.isEmpty
                              ? null
                              : () async {
                                  Get.back();
                                  await Future.wait(
                                    selected.map(
                                      (e) async => await ref
                                          .read(chronicDiseaseProvider.notifier)
                                          .addDisease(e.index),
                                    ),
                                  );
                                },
                          text: 'Add Selected',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chronicDiseasesState = ref.watch(chronicDiseaseProvider);
    return chronicDiseasesState.when(
      loading: () => const ChronicDiseaseShimmer(),
      error: (err, st) => Center(
        child: Text(
          'Error loading chronic diseases',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
      data: (chronicDiseases) {
        chronicDiseases.sort((a, b) => a.name.length.compareTo(b.name.length));
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...chronicDiseases.map(
              (e) => Chip(
                label: Text(
                  e.name,
                  overflow: TextOverflow.ellipsis,
                ),
                deleteIcon: Icon(
                  Icons.close,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onDeleted: () async => await ref
                    .read(chronicDiseaseProvider.notifier)
                    .deleteDisease(e.id),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.15),
                avatar: const Icon(
                  Icons.health_and_safety,
                  size: 18,
                  color: Config.accentColor,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            ActionChip(
              label: const Text('Add +'),
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () async => await showAddChronicDiseaseSheet(
                context,
                ref,
                chronicDiseases,
              ),
            ),
          ],
        );
      },
    );
  }
}

class AllergySection extends ConsumerWidget {
  const AllergySection({super.key});
  Future<void> showAddAllergySheet(
    BuildContext context,
    WidgetRef ref,
    List<Allergy> selectedAllergies,
  ) async {
    final theme = Theme.of(context);
    final isSmall = MediaQuery.of(context).size.width < 360;

    // Get all enum values except "None"
    final allAllergies = AllergyType.values
        .where((e) => e != AllergyType.None)
        .toList();

    // Exclude already selected
    final selectedNames = selectedAllergies.map((d) => d.name).toSet();
    final availableAllergies = allAllergies
        .where((e) => !selectedNames.contains(e.name))
        .toList();

    // Controller for selected options
    final ValueNotifier<Set<AllergyType>> selectedSet = ValueNotifier(
      <AllergyType>{},
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 25,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Top grab handle ---
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text(
                'Add  Allergies',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              if (availableAllergies.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Text(
                      'All allergies already added ✅',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                Flexible(
                  child: ValueListenableBuilder<Set<AllergyType>>(
                    valueListenable: selectedSet,
                    builder: (context, selected, _) {
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: availableAllergies.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 2,
                          color: Config.primaryColor,
                        ),
                        itemBuilder: (context, index) {
                          final disease = availableAllergies[index];
                          final isSelected = selected.contains(disease);
                          return ListTile(
                            leading: const Icon(
                              Icons.warning_amber,
                              color: Colors.amber,
                            ),
                            title: Text(
                              disease.name,
                              style: theme.textTheme.bodyLarge,
                            ),
                            trailing: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(
                                    scale: anim,
                                    child: child,
                                  ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check_circle,
                                      key: const ValueKey('checked'),
                                      color: theme.colorScheme.primary,
                                    )
                                  : Icon(
                                      Icons.circle_outlined,
                                      key: const ValueKey('unchecked'),
                                      color: theme.colorScheme.primary,
                                    ),
                            ),
                            onTap: () {
                              final newSet = {...selected};
                              if (isSelected) {
                                newSet.remove(disease);
                              } else {
                                newSet.add(disease);
                              }
                              selectedSet.value = newSet;
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),

              // --- Action buttons ---
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: CoolButton(
                      isSmall: isSmall,
                      onclick: () {
                        Get.back();
                      },

                      text: 'Cancel',
                      backgroundColor: theme.colorScheme.surface,
                      forGroundColor: theme.colorScheme.error,
                      borderColor: theme.colorScheme.error.withAlpha(110),
                    ),
                  ),
                  Expanded(
                    child: ValueListenableBuilder<Set<AllergyType>>(
                      valueListenable: selectedSet,
                      builder: (context, selected, _) {
                        return CoolButton(
                          isSmall: isSmall,
                          onclick: selected.isEmpty
                              ? null
                              : () async {
                                  Get.back();

                                  await Future.wait(
                                    selected.map(
                                      (e) async => await ref
                                          .read(allergiesProvider.notifier)
                                          .addAllergy(e.index),
                                    ),
                                  );
                                },
                          text: 'Add Selected',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allergiesState = ref.watch(allergiesProvider);
    return allergiesState.when(
      loading: () => const AllergySectionShimmer(),
      error: (err, st) => Center(
        child: Text(
          'Error loading allergies',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
      data: (allergies) {
        allergies.sort((a, b) => a.name.length.compareTo(b.name.length));
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,

          children: [
            ...allergies.map(
              (e) => Chip(
                label: Text(
                  e.name,
                  overflow: TextOverflow.ellipsis,
                ),
                deleteIcon: Icon(
                  Icons.close,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onDeleted: () async => await ref
                    .read(allergiesProvider.notifier)
                    .deleteAllergy(e.id),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.15),
                avatar: const Icon(
                  Icons.warning_amber,
                  size: 18,
                  color: Colors.amber,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            ActionChip(
              label: const Text('Add +'),
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () async => await showAddAllergySheet(
                context,
                ref,
                allergies,
              ),
            ),
          ],
        );
      },
    );
  }
}
