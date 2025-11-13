
import 'package:doctor_appointment_app/view/main_layout.dart';
import 'package:doctor_appointment_app/routes/middle_ware.dart';
import 'package:doctor_appointment_app/view/pages/appointment_details_page.dart';
import 'package:doctor_appointment_app/view/pages/auth_page.dart';
import 'package:doctor_appointment_app/view/pages/billing_page.dart';
import 'package:doctor_appointment_app/view/pages/booking_page.dart';
import 'package:doctor_appointment_app/view/pages/doctor_details.dart';
import 'package:doctor_appointment_app/view/pages/doctors_by_speciality_page.dart';
import 'package:doctor_appointment_app/view/pages/facilities_by_type_page.dart';
import 'package:doctor_appointment_app/view/pages/facility_details.dart';
import 'package:doctor_appointment_app/view/pages/medical_recors_page.dart';
import 'package:doctor_appointment_app/view/pages/success_booked.dart';



import 'package:get/get_navigation/get_navigation.dart';

class Sroutes {
  static const auth = '/';
  static const main = '/main';
  static const docDetails = '/doc_details';
  static const bookingPage = '/booking-page';
  static const successBooking = '/success-booking';
  static const facilityDetails = '/facility-details';
  static const appointmentDetails = '/appointment_details';
  static const billingPage = '/billing';
  static const medicalRecordPage = '/medical-records';
  static const doctorsBySpecialityPage = '/doctors-by-speciality-page';
  static const facilitiesByTypePage = '/facilities-by-type-page';
}

class SAppRoute {
  static final List<GetPage> pages = [
    GetPage(
      name: Sroutes.auth,
      page: () => const AuthPage(),
      middlewares: [AuthRedirectMiddleware()],
    ),
    GetPage(
      name: Sroutes.main,
      page: () => const MainLayout(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: '${Sroutes.docDetails}/:id',
      page: () => DoctorDetails(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: '${Sroutes.facilityDetails}/:id',
      page: () => FacilityDetails(),
      middlewares: [AuthGuardMiddleware()],
    ),
     GetPage(
      name: Sroutes.medicalRecordPage,
      page: () => const MedicalRecorsPage(),
      middlewares: [AuthGuardMiddleware()],
    ),
       GetPage(
      name: Sroutes.billingPage,
      page: () => const BillingPage(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(name: 
    Sroutes.doctorsBySpecialityPage,
     page: () =>  DoctorsBySpecialityPage(),
      middlewares: [AuthGuardMiddleware()],
    ),
       GetPage(
      name: Sroutes.facilitiesByTypePage,
      page: () => FacilitiesByTypePage(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: Sroutes.bookingPage,
      page: () => const BookingPage(),
      middlewares: [AuthGuardMiddleware()],
    ),
     GetPage(
      name: '${Sroutes.appointmentDetails}/:id',
      page: () => AppointmentDetailsPage(),
      middlewares: [AuthGuardMiddleware()],
    ),
    GetPage(
      name: Sroutes.successBooking,
      page: () => const AppointmentBooked(),
      middlewares: [AuthGuardMiddleware()],
    ),
  ];
}
