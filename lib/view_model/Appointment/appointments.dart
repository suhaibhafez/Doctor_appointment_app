import 'dart:async';

import 'package:doctor_appointment_app/models/Appointment/appointment.dart';
import 'package:doctor_appointment_app/services/appointment_services.dart';
import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:doctor_appointment_app/services/log_service.dart';
import 'package:doctor_appointment_app/view_model/notification.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppointmentsNotifier extends AsyncNotifier<List<Appointment>> {
  int? status;

  int _currentPage = 1;
  final int pageSize = 3;

  bool isLastPage = false;
  bool isLoadingMore = false;
  bool isCancelling = false;
  AsyncError? loadMoreError;
  AsyncError? addingAppointmentError;
  AsyncError? cacellingError;
  AsyncError? rescheduleError;
  @override
  FutureOr<List<Appointment>> build() async {
    state = const AsyncValue.loading();
    final firstPage = await fetchPage(page: _currentPage);
    if (firstPage.length < pageSize) isLastPage = true;
    return firstPage;
  }

  Future<List<Appointment>> fetchPage({required int page}) {
    final token = LocalStorageService.getToken;

    return AppointmentServices.getAppointmentsByStatus(
      page: page,
      ref: ref,
      status: status,
      pageSize: pageSize,
      token: token!,
    );
  }

  Future<void> refresh() async {
    _currentPage = 1;
    isLastPage = false;
    isLoadingMore = false;
    loadMoreError = null;
    addingAppointmentError = null;
    isCancelling = false;
    cacellingError = null;
    rescheduleError = null;
    state = const AsyncValue.loading();

    final fresh = await AsyncValue.guard(() => fetchPage(page: 1));
    fresh.whenData((data) {
      if (data.length < pageSize) isLastPage = true;
    });
    state = fresh;
  }

  Future<void> loadMore() async {
    if (isLoadingMore || isLastPage) return;
    isLoadingMore = true;
    loadMoreError = null;
    ref.notifyListeners();

    try {
      _currentPage++;
      final more = await fetchPage(page: _currentPage);

      if (more.length < pageSize) isLastPage = true;

      state = state.whenData((existing) => [...existing, ...more]);
    } catch (e, st) {
      _currentPage--;
      loadMoreError = AsyncError(e, st);
      ref.notifyListeners();
    } finally {
      isLoadingMore = false;
    }
  }

  Future<void> updateStatus(int? status) async {
    this.status = status;

    await refresh();
  }

  Future<void> addAppointment(
    String doctorId,
    String facilityId,
    String schduleDate,
    String schduleTime,
    int durationMinutes,
  ) async {
    addingAppointmentError = null;

    try {
      final token = LocalStorageService.getToken;
      await AppointmentServices.bookAppointment(
        ref,
        token!,
        doctorId,
        facilityId,
        schduleDate,
        schduleTime,
        durationMinutes,
      );
      status = null;
      await refresh();
    } catch (e, st) {
      addingAppointmentError = AsyncError(e, st);
      ref.notifyListeners();
    }
  }

  Future<void> reScheduleAppointment({
    required String id,
    required String newDate,
    required String newTime,

    String? reason,
  }) async {
    rescheduleError = null;

    try {
      final token = LocalStorageService.getToken;
      await AppointmentServices.reScheduleAppointment(
        ref: ref,
        id: id,
        token: token!,
        newDate: newDate,
        newTime: newTime,
      );

      status = null;
      final current = state.value?.firstWhere(
        (element) => element.id == id,
      );
      LogService.i('Succesful reschedule from:${current?.scheduledDate} at  ${current?.scheduledTime} to \n $newDate at $newTime');
      await refresh();
    } catch (e, st) {
      addingAppointmentError = AsyncError(e, st);
      ref.notifyListeners();
    }
  }

  Future<void> cancelAppointment(String id, String reason) async {
    if (isCancelling) {
      return;
    }
    isCancelling = true;
    cacellingError = null;
    ref.notifyListeners();
    try {
      final token = LocalStorageService.getToken;
      await AppointmentServices.cancelAppointment(
        id: id,
        ref: ref,
        token: token!,
        reason: reason,
      );
      if (!ref.read(signalRServiceProvider).isConnected) {
        status = null;

        await refresh();
      }
      LogService.i('Status on cancelling:$status');
    } catch (e, st) {
      cacellingError = AsyncError(e, st);
      ref.notifyListeners();
      LogService.e('Error cancelling Appointment: ', e, st);
    } finally {
      isCancelling = false;

      ref.notifyListeners();
    }
  }
}

final appointmentsProvider =
    AsyncNotifierProvider<AppointmentsNotifier, List<Appointment>>(
      AppointmentsNotifier.new,
    );
