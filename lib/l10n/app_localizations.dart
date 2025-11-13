import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @signInToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInToYourAccount;

  /// No description provided for @nationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalId;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @forgotYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Your Password?'**
  String get forgotYourPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signUpDescription.
  ///
  /// In en, this message translates to:
  /// **'You can easily sign up, and connect to the Doctors nearby you'**
  String get signUpDescription;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @specialization.
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get specialization;

  /// No description provided for @appointmentToday.
  ///
  /// In en, this message translates to:
  /// **'Appointment Today'**
  String get appointmentToday;

  /// No description provided for @topDoctors.
  ///
  /// In en, this message translates to:
  /// **'Top Doctors'**
  String get topDoctors;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @doctors.
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get doctors;

  /// No description provided for @facilities.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get facilities;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @canceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get canceled;

  /// No description provided for @reschedule.
  ///
  /// In en, this message translates to:
  /// **'Reschedule'**
  String get reschedule;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @medicalRecord.
  ///
  /// In en, this message translates to:
  /// **'Medical Record'**
  String get medicalRecord;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @dr.
  ///
  /// In en, this message translates to:
  /// **'Dr.'**
  String get dr;

  /// No description provided for @doctorDetails.
  ///
  /// In en, this message translates to:
  /// **'Doctor Details'**
  String get doctorDetails;

  /// No description provided for @bookAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookAppointment;

  /// No description provided for @makeAppointment.
  ///
  /// In en, this message translates to:
  /// **'Make Appointment'**
  String get makeAppointment;

  /// No description provided for @successfullyBooked.
  ///
  /// In en, this message translates to:
  /// **'Successfully Booked'**
  String get successfullyBooked;

  /// No description provided for @backToHomePage.
  ///
  /// In en, this message translates to:
  /// **'Back to home page'**
  String get backToHomePage;

  /// No description provided for @speciality_Cardiology.
  ///
  /// In en, this message translates to:
  /// **'Cardiology'**
  String get speciality_Cardiology;

  /// No description provided for @speciality_Dermatology.
  ///
  /// In en, this message translates to:
  /// **'Dermatology'**
  String get speciality_Dermatology;

  /// No description provided for @speciality_Endocrinology.
  ///
  /// In en, this message translates to:
  /// **'Endocrinology'**
  String get speciality_Endocrinology;

  /// No description provided for @speciality_Gastroenterology.
  ///
  /// In en, this message translates to:
  /// **'Gastroenterology'**
  String get speciality_Gastroenterology;

  /// No description provided for @speciality_Hematology.
  ///
  /// In en, this message translates to:
  /// **'Hematology'**
  String get speciality_Hematology;

  /// No description provided for @speciality_InfectiousDisease.
  ///
  /// In en, this message translates to:
  /// **'Infectious Disease'**
  String get speciality_InfectiousDisease;

  /// No description provided for @speciality_Nephrology.
  ///
  /// In en, this message translates to:
  /// **'Nephrology'**
  String get speciality_Nephrology;

  /// No description provided for @speciality_Neurology.
  ///
  /// In en, this message translates to:
  /// **'Neurology'**
  String get speciality_Neurology;

  /// No description provided for @speciality_Oncology.
  ///
  /// In en, this message translates to:
  /// **'Oncology'**
  String get speciality_Oncology;

  /// No description provided for @speciality_Pediatrics.
  ///
  /// In en, this message translates to:
  /// **'Pediatrics'**
  String get speciality_Pediatrics;

  /// No description provided for @speciality_Psychiatry.
  ///
  /// In en, this message translates to:
  /// **'Psychiatry'**
  String get speciality_Psychiatry;

  /// No description provided for @speciality_Pulmonology.
  ///
  /// In en, this message translates to:
  /// **'Pulmonology'**
  String get speciality_Pulmonology;

  /// No description provided for @speciality_Rheumatology.
  ///
  /// In en, this message translates to:
  /// **'Rheumatology'**
  String get speciality_Rheumatology;

  /// No description provided for @speciality_Surgery.
  ///
  /// In en, this message translates to:
  /// **'Surgery'**
  String get speciality_Surgery;

  /// No description provided for @speciality_Urology.
  ///
  /// In en, this message translates to:
  /// **'Urology'**
  String get speciality_Urology;

  /// No description provided for @speciality_Ophthalmology.
  ///
  /// In en, this message translates to:
  /// **'Ophthalmology'**
  String get speciality_Ophthalmology;

  /// No description provided for @speciality_Orthopedics.
  ///
  /// In en, this message translates to:
  /// **'Orthopedics'**
  String get speciality_Orthopedics;

  /// No description provided for @speciality_Anesthesiology.
  ///
  /// In en, this message translates to:
  /// **'Anesthesiology'**
  String get speciality_Anesthesiology;

  /// No description provided for @speciality_Radiology.
  ///
  /// In en, this message translates to:
  /// **'Radiology'**
  String get speciality_Radiology;

  /// No description provided for @speciality_EmergencyMedicine.
  ///
  /// In en, this message translates to:
  /// **'Emergency Medicine'**
  String get speciality_EmergencyMedicine;

  /// No description provided for @speciality_FamilyMedicine.
  ///
  /// In en, this message translates to:
  /// **'Family Medicine'**
  String get speciality_FamilyMedicine;

  /// No description provided for @speciality_InternalMedicine.
  ///
  /// In en, this message translates to:
  /// **'Internal Medicine'**
  String get speciality_InternalMedicine;

  /// No description provided for @speciality_ObstetricsGynecology.
  ///
  /// In en, this message translates to:
  /// **'Obstetrics & Gynecology'**
  String get speciality_ObstetricsGynecology;

  /// No description provided for @speciality_Pathology.
  ///
  /// In en, this message translates to:
  /// **'Pathology'**
  String get speciality_Pathology;

  /// No description provided for @speciality_PhysicalMedicine.
  ///
  /// In en, this message translates to:
  /// **'Physical Medicine'**
  String get speciality_PhysicalMedicine;

  /// No description provided for @speciality_Other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get speciality_Other;

  /// No description provided for @facility_Hospital.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get facility_Hospital;

  /// No description provided for @facility_Clinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get facility_Clinic;

  /// No description provided for @facility_Pharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get facility_Pharmacy;

  /// No description provided for @facility_DiagnosticCenter.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic Center'**
  String get facility_DiagnosticCenter;

  /// No description provided for @facility_RehabilitationCenter.
  ///
  /// In en, this message translates to:
  /// **'Rehabilitation Center'**
  String get facility_RehabilitationCenter;

  /// No description provided for @facility_NursingHome.
  ///
  /// In en, this message translates to:
  /// **'Nursing Home'**
  String get facility_NursingHome;

  /// No description provided for @facility_Laboratory.
  ///
  /// In en, this message translates to:
  /// **'Laboratory'**
  String get facility_Laboratory;

  /// No description provided for @facility_UrgentCare.
  ///
  /// In en, this message translates to:
  /// **'Urgent Care'**
  String get facility_UrgentCare;

  /// No description provided for @facility_SpecializedCenter.
  ///
  /// In en, this message translates to:
  /// **'Specialized Center'**
  String get facility_SpecializedCenter;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
