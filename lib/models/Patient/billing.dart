
import 'package:doctor_appointment_app/models/Doctor/doctor.dart';

import 'package:doctor_appointment_app/models/Patient/patient.dart';

class Billing {
  final String id;
  final double totalAmount;
  final String status;
  final DateTime dateIssued;
  final DateTime? paymentDate;
  final double? paidAmount;
  final Doctor? doctor;
  final BillingAppointmentMini? appointment;
  final Patient? patient;

  const Billing({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.dateIssued,
    this.paymentDate,
    this.paidAmount,
    this.doctor,
    this.appointment,
    this.patient,
  });

  factory Billing.fromJson(Map<String, dynamic> json) {
    return Billing(
      id: json['id'],
      totalAmount: json['totalAmount'],
      status: json['status'],
      dateIssued: DateTime.parse(json['dateIssued']),
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : null,
      paidAmount: json['paidAmount'] != null
          ? (json['paidAmount'] as num).toDouble()
          : null,
    );
  }
  factory Billing.fromBillingAPi(Map<String, dynamic> json) {
    return Billing(
      id: json['Id'],
      totalAmount: json['TotalAmount'],
      status: json['Status'],
      dateIssued: DateTime.parse(json['DateIssued']),
      paymentDate: json['PaymentDate'] != null
          ? DateTime.parse(json['PaymentDate'])
          : null,
      paidAmount: json['PaidAmount'] != null
          ? (json['PaidAmount'] as num).toDouble()
          : null,
      doctor: Doctor.fromAppointmentApi(json['Doctor']),
      appointment: BillingAppointmentMini.fromJson(json['Appointment']),    
      patient: Patient.fromAppointmentJson(json['Patient']),    

    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'totalAmount': totalAmount,
      'status': status,
      'dateIssued': dateIssued.toIso8601String(),
      'paymentDate': paymentDate?.toIso8601String(),
      'paidAmount': paidAmount,
    };
  }
}

class BillingAppointmentMini {
  final String id;
  final DateTime scheduledDate;
  final String scheduledTime;
  final String status;
  
  BillingAppointmentMini({
    required this.id,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.status,
  });
  factory BillingAppointmentMini.fromJson(Map<String, dynamic> json) {
    return BillingAppointmentMini(
      id: json['id'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      scheduledTime: json['scheduledTime'],
      status: json['status'],
    );
  }

}