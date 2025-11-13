import 'dart:async';

import 'package:doctor_appointment_app/models/Patient/billing.dart';
import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:doctor_appointment_app/services/patient_services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
class BillingsNotifier extends AsyncNotifier<List<Billing>> {
 

  int _currentPage = 1;
  final int pageSize = 3;

  bool isLastPage = false;
  bool isLoadingMore = false;
  AsyncError? loadMoreError;
  @override
  FutureOr<List<Billing>> build() async {
    state = const AsyncValue.loading();
    final firstPage = await fetchPage(page: _currentPage);
    if (firstPage.length < pageSize) isLastPage = true;
    return firstPage;
  }

  Future<List<Billing>> fetchPage({required int page}) {
    return PatientService.getBillings(
      LocalStorageService.getToken!,
      ref,
    page, pageSize
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

 

}
final billingsProvider = AsyncNotifierProvider(
  BillingsNotifier.new,
 
);
