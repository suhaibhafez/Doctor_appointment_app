import 'dart:async';
import 'package:doctor_appointment_app/models/Doctor/doctor.dart';
import 'package:doctor_appointment_app/services/doctor_services.dart';
import 'package:flutter/material.dart';


import 'package:flutter_riverpod/flutter_riverpod.dart';

class DoctorsNotifier extends AsyncNotifier<List<Doctor>> {
  

  String? q;
  int? specialization;

  int _currentPage = 1;
  final int pageSize = 6;

  bool isLastPage = false;
  bool isLoadingMore = false;
  AsyncError? loadMoreError;
  DoctorsNotifier(this.specialization);
  @override
  FutureOr<List<Doctor>> build() async {
    state = const AsyncValue.loading();
    debugPrint('Building DoctorsNotifier with specialization: $specialization');
    final firstPage = await fetchPage(page: _currentPage);
    if (firstPage.length < pageSize) isLastPage = true;
    return firstPage;
  }

  Future<List<Doctor>> fetchPage({required int page}) {
    return DoctorService.getDoctors(
      ref,
      page,
      pageSize,
      specialization,
      q,
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

  Future<void> updateSearch(String? newQuery) async {
    q = (newQuery == null || newQuery.trim().isEmpty) ? null : newQuery;
    await refresh();
  }

  Future<void> updateSpecialization(int? newSpecialization) async {
    specialization = newSpecialization;
    await refresh();
  }

  Future<void> clearFilters() async {
    q = null;
    specialization = null;
    await refresh();
  }
}

final doctorProvider = AsyncNotifierProvider.autoDispose.family<DoctorsNotifier, List<Doctor>,int?>(
  (arg) => DoctorsNotifier(arg),
);
