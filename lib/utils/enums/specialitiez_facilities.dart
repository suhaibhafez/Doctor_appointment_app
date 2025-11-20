import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

/// =======================
/// Facility Type Enum
/// =======================
enum FacilityType {
  hospital,
  clinic,
  pharmacy,
  laboratory,
  diagnosticCenter,
  rehabilitationCenter,
  nursingHome,
  urgentCare,
  specializedCenter,
}

/// Returns list of maps with icon + localized name
List<Map<String, dynamic>> getFacilityTypesList(BuildContext context) {
  final t = AppLocalizations.of(context)!;

  // Keep the order same as enum declaration
  final List<Map<String, dynamic>> facilityData = [
   {
      "icon": FontAwesomeIcons.hospital,
      "category": t.facility_Hospital,
      "key": "Hospital",
    },
    {
      "icon": FontAwesomeIcons.clinicMedical,
      "category": t.facility_Clinic,
      "key": "Clinic",
    },
    {
      "icon": FontAwesomeIcons.prescriptionBottleMedical,
      "category": t.facility_Pharmacy,
      "key": "Pharmacy",
    },
    {
      "icon": FontAwesomeIcons.microscope,
      "category": t.facility_Laboratory,
      "key": "Laboratory",
    },
    {
      "icon": FontAwesomeIcons.xRay,
      "category": t.facility_DiagnosticCenter,
      "key": "DiagnosticCenter",
    },
    {
      "icon": FontAwesomeIcons.wheelchair,
      "category": t.facility_RehabilitationCenter,
      "key": "RehabilitationCenter",
    },
    {
      "icon": FontAwesomeIcons.houseUser,
      "category": t.facility_NursingHome,
      "key": "NursingHome",
    },
    {
      "icon": FontAwesomeIcons.truckMedical,
      "category": t.facility_UrgentCare,
      "key": "UrgentCare",
    },
    {
      "icon": FontAwesomeIcons.buildingUser,
      "category": t.facility_SpecializedCenter,
      "key": "SpecializedCenter",
    },
  ];
  

  return List.generate(
    FacilityType.values.length,
    (index) => facilityData[index],
  );
}

/// =======================
/// Speciality Enum
/// =======================
///
enum Speciality {
  none,
  cardiology,
  dermatology,
  endocrinology,
  gastroenterology,
  hematology,
  infectiousDisease,
  nephrology,
  neurology,
  oncology,
  pediatrics,
  psychiatry,
  pulmonology,
  rheumatology,
  surgery,
  urology,
  ophthalmology,
  orthopedics,
  anesthesiology,
  radiology,
  emergencyMedicine,
  familyMedicine,
  internalMedicine,
  obstetricsGynecology,
  pathology,
  physicalMedicine,
  other,
}

/// Returns list of maps with icon + localized name
List<Map<String, dynamic>> getSpecialitiesList(BuildContext context) {
  final t = AppLocalizations.of(context)!;

  final List<Map<String, dynamic>> specialityData = [
    {'icon': null, 'category': ''},
    {"icon": FontAwesomeIcons.heartPulse, "category": t.speciality_Cardiology},
    {"icon": FontAwesomeIcons.hand, "category": t.speciality_Dermatology},
    {"icon": FontAwesomeIcons.droplet, "category": t.speciality_Endocrinology},
    {
      "icon": FontAwesomeIcons.bowlFood,
      "category": t.speciality_Gastroenterology,
    },
    {"icon": FontAwesomeIcons.vial, "category": t.speciality_Hematology},
    {
      "icon": FontAwesomeIcons.virus,
      "category": t.speciality_InfectiousDisease,
    },
    {"icon": FontAwesomeIcons.flask, "category": t.speciality_Nephrology},
    {"icon": FontAwesomeIcons.brain, "category": t.speciality_Neurology},
    {"icon": FontAwesomeIcons.dna, "category": t.speciality_Oncology},
    {"icon": FontAwesomeIcons.baby, "category": t.speciality_Pediatrics},
    {"icon": FontAwesomeIcons.userGroup, "category": t.speciality_Psychiatry},
    {"icon": FontAwesomeIcons.lungs, "category": t.speciality_Pulmonology},
    {"icon": FontAwesomeIcons.bone, "category": t.speciality_Rheumatology},
    {"icon": FontAwesomeIcons.nonBinary, "category": t.speciality_Surgery},
    {"icon": FontAwesomeIcons.toilet, "category": t.speciality_Urology},
    {"icon": FontAwesomeIcons.eye, "category": t.speciality_Ophthalmology},
    {
      "icon": FontAwesomeIcons.personWalking,
      "category": t.speciality_Orthopedics,
    },
    {"icon": FontAwesomeIcons.syringe, "category": t.speciality_Anesthesiology},
    {"icon": FontAwesomeIcons.radiation, "category": t.speciality_Radiology},
    {
      "icon": FontAwesomeIcons.truckMedical,
      "category": t.speciality_EmergencyMedicine,
    },
    {
      "icon": FontAwesomeIcons.houseChimneyMedical,
      "category": t.speciality_FamilyMedicine,
    },
    {
      "icon": FontAwesomeIcons.stethoscope,
      "category": t.speciality_InternalMedicine,
    },
    {
      "icon": FontAwesomeIcons.personPregnant,
      "category": t.speciality_ObstetricsGynecology,
    },
    {"icon": FontAwesomeIcons.microscope, "category": t.speciality_Pathology},
    {
      "icon": FontAwesomeIcons.personRunning,
      "category": t.speciality_PhysicalMedicine,
    },
    {"icon": FontAwesomeIcons.circleQuestion, "category": t.speciality_Other},
  ];

  return List.generate(
    Speciality.values.length,
    (index) => specialityData[index],
  );
}

dynamic getLocalizedSpe(String spe, BuildContext context, bool icon) {
  final t = AppLocalizations.of(context)!;
  final index = Speciality.values.indexWhere(
    (sp) => sp.name == lowerFirst(spe),
  );

  if (index == -1) {
    // Fallback to "Other" or a default text
    return t.speciality_Other;
  }
  final special = getSpecialitiesList(context)[index];
  if (icon == false) {
    return special['category'];
  } else {
    return special['icon'];
  }
}

int? getspecialityIndex(String? spe) {
  if (spe == null || spe.isEmpty) {
    return null;
  }
  return Speciality.values.indexWhere((sp) => capitalizeFirst(sp.name) == spe);
}

String? capitalizeFirst(String? str) {
  if (str == null) return null;

  if (str.isEmpty) return '';
  return str[0].toUpperCase() + str.substring(1);
}

String? lowerFirst(String? str) {
  if (str == null) return null;

  if (str.isEmpty) return '';
  return str[0].toLowerCase() + str.substring(1);
}
