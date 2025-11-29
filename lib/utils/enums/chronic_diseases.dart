  // ignore_for_file: constant_identifier_names

  import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

enum ChronicDiseaseType
    {
        
        None,
        Diabetes,
        Hypertension,
        Asthma,
        HeartDisease,
        ChronicKidneyDisease,
        ChronicLiverDisease,
        Epilepsy,
        COPD, // Chronic Obstructive Pulmonary Disease
        Arthritis,
        Cancer,
        Depression,
        Anxiety,
        ThyroidDisorder,
        Osteoporosis,
        Alzheimer,
        Parkinson,
        HIV,
        Hepatitis,
        Stroke,
        Tuberculosis,
        Obesity,
        Other
    }


String getLocalizedChronicDisease(BuildContext context, String disease) {
  final l10n = AppLocalizations.of(context);
  
  switch (disease) {
    case 'Diabetes':
      return l10n?.chronicDisease_Diabetes ?? 'Diabetes';
    case 'Hypertension':
      return l10n?.chronicDisease_Hypertension ?? 'Hypertension';
    case 'Asthma':
      return l10n?.chronicDisease_Asthma ?? 'Asthma';
    case 'HeartDisease':
      return l10n?.chronicDisease_HeartDisease ?? 'Heart Disease';
    case 'ChronicKidneyDisease':
      return l10n?.chronicDisease_ChronicKidneyDisease ?? 'Chronic Kidney Disease';
    case 'ChronicLiverDisease':
      return l10n?.chronicDisease_ChronicLiverDisease ?? 'Chronic Liver Disease';
    case 'Epilepsy':
      return l10n?.chronicDisease_Epilepsy ?? 'Epilepsy';
    case 'COPD':
      return l10n?.chronicDisease_COPD ?? 'COPD';
    case 'Arthritis':
      return l10n?.chronicDisease_Arthritis ?? 'Arthritis';
    case 'Cancer':
      return l10n?.chronicDisease_Cancer ?? 'Cancer';
    case 'Depression':
      return l10n?.chronicDisease_Depression ?? 'Depression';
    case 'Anxiety':
      return l10n?.chronicDisease_Anxiety ?? 'Anxiety';
    case 'ThyroidDisorder':
      return l10n?.chronicDisease_ThyroidDisorder ?? 'Thyroid Disorder';
    case 'Osteoporosis':
      return l10n?.chronicDisease_Osteoporosis ?? 'Osteoporosis';
    case 'Alzheimer':
      return l10n?.chronicDisease_Alzheimer ?? 'Alzheimer';
    case 'Parkinson':
      return l10n?.chronicDisease_Parkinson ?? 'Parkinson';
    case 'HIV':
      return l10n?.chronicDisease_HIV ?? 'HIV';
    case 'Hepatitis':
      return l10n?.chronicDisease_Hepatitis ?? 'Hepatitis';
    case 'Stroke':
      return l10n?.chronicDisease_Stroke ?? 'Stroke';
    case 'Tuberculosis':
      return l10n?.chronicDisease_Tuberculosis ?? 'Tuberculosis';
    case 'Obesity':
      return l10n?.chronicDisease_Obesity ?? 'Obesity';
    case 'Other':
      return l10n?.chronicDisease_Other ?? 'Other';
    default:
      return l10n?.chronicDisease_Other ?? 'Other';
  }
}    