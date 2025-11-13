import 'dart:async';

import 'package:doctor_appointment_app/models/Appointment/appointment.dart';
import 'package:doctor_appointment_app/services/appointment_services.dart';
import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppointmentsNotifier extends AsyncNotifier<List<Appointment>> {
  int? status;

  int _currentPage = 1;
  final int pageSize = 3;

  bool isLastPage = false;
  bool isLoadingMore = false;
  AsyncError? loadMoreError;
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
}

final appointmentsProvider =
    AsyncNotifierProvider<AppointmentsNotifier, List<Appointment>>(
      AppointmentsNotifier.new,
    );
