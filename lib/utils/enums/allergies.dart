// ignore_for_file: constant_identifier_names

import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';

enum AllergyType {
  None,
  Penicillin,
  Amoxicillin,
  SulfaDrugs,
  NSAIDs,
  Aspirin,
  Codeine,
  Morphine,
  Latex,
  Peanuts,
  TreeNuts,
  Shellfish,
  Fish,
  Eggs,
  Milk,
  Soy,
  Wheat,
  Pollen,
  DustMites,
  Mold,
  PetDander,
  BeeStings,
  InsectStings,
  Other,
}


String getLocalizedAllergy(BuildContext context, String allergy) {
  final l10n = AppLocalizations.of(context);
  
  switch (allergy) {
    case 'Penicillin':
      return l10n?.allergy_Penicillin ?? 'Penicillin';
    case 'Amoxicillin':
      return l10n?.allergy_Amoxicillin ?? 'Amoxicillin';
    case 'SulfaDrugs':
      return l10n?.allergy_SulfaDrugs ?? 'Sulfa Drugs';
    case 'NSAIDs':
      return l10n?.allergy_NSAIDs ?? 'NSAIDs';
    case 'Aspirin':
      return l10n?.allergy_Aspirin ?? 'Aspirin';
    case 'Codeine':
      return l10n?.allergy_Codeine ?? 'Codeine';
    case 'Morphine':
      return l10n?.allergy_Morphine ?? 'Morphine';
    case 'Latex':
      return l10n?.allergy_Latex ?? 'Latex';
    case 'Peanuts':
      return l10n?.allergy_Peanuts ?? 'Peanuts';
    case 'TreeNuts':
      return l10n?.allergy_TreeNuts ?? 'Tree Nuts';
    case 'Shellfish':
      return l10n?.allergy_Shellfish ?? 'Shellfish';
    case 'Fish':
      return l10n?.allergy_Fish ?? 'Fish';
    case 'Eggs':
      return l10n?.allergy_Eggs ?? 'Eggs';
    case 'Milk':
      return l10n?.allergy_Milk ?? 'Milk';
    case 'Soy':
      return l10n?.allergy_Soy ?? 'Soy';
    case 'Wheat':
      return l10n?.allergy_Wheat ?? 'Wheat';
    case 'Pollen':
      return l10n?.allergy_Pollen ?? 'Pollen';
    case 'DustMites':
      return l10n?.allergy_DustMites ?? 'Dust Mites';
    case 'Mold':
      return l10n?.allergy_Mold ?? 'Mold';
    case 'PetDander':
      return l10n?.allergy_PetDander ?? 'Pet Dander';
    case 'BeeStings':
      return l10n?.allergy_BeeStings ?? 'Bee Stings';
    case 'InsectStings':
      return l10n?.allergy_InsectStings ?? 'Insect Stings';
    case 'Other':
      return l10n?.allergy_Other ?? 'Other';
    default:
      return l10n?.allergy_Other ?? 'Other';
  }
}