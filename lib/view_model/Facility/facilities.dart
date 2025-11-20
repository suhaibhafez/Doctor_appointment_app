import 'dart:async';

import 'package:doctor_appointment_app/models/Facility/facility.dart';
import 'package:doctor_appointment_app/services/facility_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FacilitiesNotifier extends AsyncNotifier<List<Facility>> {
  String? q;
  String? type;

  int _currentPage = 1;
  final int pageSize = 6;

  bool isLastPage = false;
  bool isLoadingMore = false;
  AsyncError? loadMoreError;
  FacilitiesNotifier(this.type);
  @override
  FutureOr<List<Facility>> build() async {
    state = const AsyncValue.loading();
   
    final firstPage = await fetchPage(page: _currentPage);
    if (firstPage.length < pageSize) isLastPage = true;
    return firstPage;
  }

  Future<List<Facility>> fetchPage({required int page}) {
    return FacilityServices.getFacilities(
      ref,
      page,
      pageSize,
      type,
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
      _currentPage--; // roll back page number

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

  Future<void> updateType(String? newType) async {
    type = newType;
    await refresh();
  }

  Future<void> clearFilters() async {
    q = null;
    type = null;
    await refresh();
  }
}

final facilitiesProvider =
    AsyncNotifierProvider.autoDispose.family<FacilitiesNotifier, List<Facility>,String?>(
    (arg) => FacilitiesNotifier(arg),
    );
