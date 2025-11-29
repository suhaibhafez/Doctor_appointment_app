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
  /// **'Don\'t have an account?'**
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

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

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
  /// **'Confirm Appointment'**
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

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @rebook.
  ///
  /// In en, this message translates to:
  /// **'Rebook'**
  String get rebook;

  /// No description provided for @moreInfo.
  ///
  /// In en, this message translates to:
  /// **'More info'**
  String get moreInfo;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @todaysAppointments.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Appointments'**
  String get todaysAppointments;

  /// No description provided for @exploreSpecialities.
  ///
  /// In en, this message translates to:
  /// **'Explore Specialities'**
  String get exploreSpecialities;

  /// No description provided for @exploreFacilities.
  ///
  /// In en, this message translates to:
  /// **'Explore Facilities'**
  String get exploreFacilities;

  /// No description provided for @noDoctorsFound.
  ///
  /// In en, this message translates to:
  /// **'No doctors found'**
  String get noDoctorsFound;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @billings.
  ///
  /// In en, this message translates to:
  /// **'Billings'**
  String get billings;

  /// No description provided for @medicalHistory.
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get medicalHistory;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @contacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts;

  /// No description provided for @emails.
  ///
  /// In en, this message translates to:
  /// **'Emails'**
  String get emails;

  /// No description provided for @phoneNumbers.
  ///
  /// In en, this message translates to:
  /// **'Phone Numbers'**
  String get phoneNumbers;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get getDirections;

  /// No description provided for @confirmAppointment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Appointment'**
  String get confirmAppointment;

  /// No description provided for @selectConsultationTime.
  ///
  /// In en, this message translates to:
  /// **'Select Consultation Time'**
  String get selectConsultationTime;

  /// No description provided for @medicalDepartments.
  ///
  /// In en, this message translates to:
  /// **'Medical Departments'**
  String get medicalDepartments;

  /// No description provided for @specializedDoctors.
  ///
  /// In en, this message translates to:
  /// **'Specialized Doctors'**
  String get specializedDoctors;

  /// No description provided for @browseDepartmentsAndFindSpecializedDoctors.
  ///
  /// In en, this message translates to:
  /// **'Browse departments and find specialized doctors'**
  String get browseDepartmentsAndFindSpecializedDoctors;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @experiencedMedicalProfessionalsIn.
  ///
  /// In en, this message translates to:
  /// **'Experienced medical professionals in'**
  String get experiencedMedicalProfessionalsIn;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @appointmentInfo.
  ///
  /// In en, this message translates to:
  /// **'Appointment Info'**
  String get appointmentInfo;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @bookedOn.
  ///
  /// In en, this message translates to:
  /// **'Booked on'**
  String get bookedOn;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get checkIn;

  /// No description provided for @checkOut.
  ///
  /// In en, this message translates to:
  /// **'Check-out'**
  String get checkOut;

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @doctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// No description provided for @facility.
  ///
  /// In en, this message translates to:
  /// **'Facility'**
  String get facility;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @street.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// No description provided for @billing.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get billing;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @issued.
  ///
  /// In en, this message translates to:
  /// **'Issued'**
  String get issued;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @paidOn.
  ///
  /// In en, this message translates to:
  /// **'Paid On'**
  String get paidOn;

  /// No description provided for @prescriptions.
  ///
  /// In en, this message translates to:
  /// **'Prescriptions'**
  String get prescriptions;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @appointmentStatusAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get appointmentStatusAll;

  /// No description provided for @appointmentStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get appointmentStatusPending;

  /// No description provided for @appointmentStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get appointmentStatusConfirmed;

  /// No description provided for @appointmentStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get appointmentStatusCompleted;

  /// No description provided for @appointmentStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get appointmentStatusCancelled;

  /// No description provided for @chronicDiseases.
  ///
  /// In en, this message translates to:
  /// **'Chronic Diseases'**
  String get chronicDiseases;

  /// No description provided for @chronicDisease_Diabetes.
  ///
  /// In en, this message translates to:
  /// **'Diabetes'**
  String get chronicDisease_Diabetes;

  /// No description provided for @chronicDisease_Hypertension.
  ///
  /// In en, this message translates to:
  /// **'Hypertension'**
  String get chronicDisease_Hypertension;

  /// No description provided for @chronicDisease_Asthma.
  ///
  /// In en, this message translates to:
  /// **'Asthma'**
  String get chronicDisease_Asthma;

  /// No description provided for @chronicDisease_HeartDisease.
  ///
  /// In en, this message translates to:
  /// **'Heart Disease'**
  String get chronicDisease_HeartDisease;

  /// No description provided for @chronicDisease_ChronicKidneyDisease.
  ///
  /// In en, this message translates to:
  /// **'Chronic Kidney Disease'**
  String get chronicDisease_ChronicKidneyDisease;

  /// No description provided for @chronicDisease_ChronicLiverDisease.
  ///
  /// In en, this message translates to:
  /// **'Chronic Liver Disease'**
  String get chronicDisease_ChronicLiverDisease;

  /// No description provided for @chronicDisease_Epilepsy.
  ///
  /// In en, this message translates to:
  /// **'Epilepsy'**
  String get chronicDisease_Epilepsy;

  /// No description provided for @chronicDisease_COPD.
  ///
  /// In en, this message translates to:
  /// **'COPD'**
  String get chronicDisease_COPD;

  /// No description provided for @chronicDisease_Arthritis.
  ///
  /// In en, this message translates to:
  /// **'Arthritis'**
  String get chronicDisease_Arthritis;

  /// No description provided for @chronicDisease_Cancer.
  ///
  /// In en, this message translates to:
  /// **'Cancer'**
  String get chronicDisease_Cancer;

  /// No description provided for @chronicDisease_Depression.
  ///
  /// In en, this message translates to:
  /// **'Depression'**
  String get chronicDisease_Depression;

  /// No description provided for @chronicDisease_Anxiety.
  ///
  /// In en, this message translates to:
  /// **'Anxiety'**
  String get chronicDisease_Anxiety;

  /// No description provided for @chronicDisease_ThyroidDisorder.
  ///
  /// In en, this message translates to:
  /// **'Thyroid Disorder'**
  String get chronicDisease_ThyroidDisorder;

  /// No description provided for @chronicDisease_Osteoporosis.
  ///
  /// In en, this message translates to:
  /// **'Osteoporosis'**
  String get chronicDisease_Osteoporosis;

  /// No description provided for @chronicDisease_Alzheimer.
  ///
  /// In en, this message translates to:
  /// **'Alzheimer'**
  String get chronicDisease_Alzheimer;

  /// No description provided for @chronicDisease_Parkinson.
  ///
  /// In en, this message translates to:
  /// **'Parkinson'**
  String get chronicDisease_Parkinson;

  /// No description provided for @chronicDisease_HIV.
  ///
  /// In en, this message translates to:
  /// **'HIV'**
  String get chronicDisease_HIV;

  /// No description provided for @chronicDisease_Hepatitis.
  ///
  /// In en, this message translates to:
  /// **'Hepatitis'**
  String get chronicDisease_Hepatitis;

  /// No description provided for @chronicDisease_Stroke.
  ///
  /// In en, this message translates to:
  /// **'Stroke'**
  String get chronicDisease_Stroke;

  /// No description provided for @chronicDisease_Tuberculosis.
  ///
  /// In en, this message translates to:
  /// **'Tuberculosis'**
  String get chronicDisease_Tuberculosis;

  /// No description provided for @chronicDisease_Obesity.
  ///
  /// In en, this message translates to:
  /// **'Obesity'**
  String get chronicDisease_Obesity;

  /// No description provided for @chronicDisease_Other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get chronicDisease_Other;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @allergy_Penicillin.
  ///
  /// In en, this message translates to:
  /// **'Penicillin'**
  String get allergy_Penicillin;

  /// No description provided for @allergy_Amoxicillin.
  ///
  /// In en, this message translates to:
  /// **'Amoxicillin'**
  String get allergy_Amoxicillin;

  /// No description provided for @allergy_SulfaDrugs.
  ///
  /// In en, this message translates to:
  /// **'Sulfa Drugs'**
  String get allergy_SulfaDrugs;

  /// No description provided for @allergy_NSAIDs.
  ///
  /// In en, this message translates to:
  /// **'NSAIDs'**
  String get allergy_NSAIDs;

  /// No description provided for @allergy_Aspirin.
  ///
  /// In en, this message translates to:
  /// **'Aspirin'**
  String get allergy_Aspirin;

  /// No description provided for @allergy_Codeine.
  ///
  /// In en, this message translates to:
  /// **'Codeine'**
  String get allergy_Codeine;

  /// No description provided for @allergy_Morphine.
  ///
  /// In en, this message translates to:
  /// **'Morphine'**
  String get allergy_Morphine;

  /// No description provided for @allergy_Latex.
  ///
  /// In en, this message translates to:
  /// **'Latex'**
  String get allergy_Latex;

  /// No description provided for @allergy_Peanuts.
  ///
  /// In en, this message translates to:
  /// **'Peanuts'**
  String get allergy_Peanuts;

  /// No description provided for @allergy_TreeNuts.
  ///
  /// In en, this message translates to:
  /// **'Tree Nuts'**
  String get allergy_TreeNuts;

  /// No description provided for @allergy_Shellfish.
  ///
  /// In en, this message translates to:
  /// **'Shellfish'**
  String get allergy_Shellfish;

  /// No description provided for @allergy_Fish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get allergy_Fish;

  /// No description provided for @allergy_Eggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get allergy_Eggs;

  /// No description provided for @allergy_Milk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get allergy_Milk;

  /// No description provided for @allergy_Soy.
  ///
  /// In en, this message translates to:
  /// **'Soy'**
  String get allergy_Soy;

  /// No description provided for @allergy_Wheat.
  ///
  /// In en, this message translates to:
  /// **'Wheat'**
  String get allergy_Wheat;

  /// No description provided for @allergy_Pollen.
  ///
  /// In en, this message translates to:
  /// **'Pollen'**
  String get allergy_Pollen;

  /// No description provided for @allergy_DustMites.
  ///
  /// In en, this message translates to:
  /// **'Dust Mites'**
  String get allergy_DustMites;

  /// No description provided for @allergy_Mold.
  ///
  /// In en, this message translates to:
  /// **'Mold'**
  String get allergy_Mold;

  /// No description provided for @allergy_PetDander.
  ///
  /// In en, this message translates to:
  /// **'Pet Dander'**
  String get allergy_PetDander;

  /// No description provided for @allergy_BeeStings.
  ///
  /// In en, this message translates to:
  /// **'Bee Stings'**
  String get allergy_BeeStings;

  /// No description provided for @allergy_InsectStings.
  ///
  /// In en, this message translates to:
  /// **'Insect Stings'**
  String get allergy_InsectStings;

  /// No description provided for @allergy_Other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get allergy_Other;
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
