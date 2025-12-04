// lib/view/pages/main_layout.dart
import 'dart:async';

import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:doctor_appointment_app/models/Patient/patient.dart';
import 'package:doctor_appointment_app/models/notification_model.dart';
import 'package:doctor_appointment_app/routes/routes.dart';
import 'package:doctor_appointment_app/services/local_storage_services.dart';
import 'package:doctor_appointment_app/services/log_service.dart';
import 'package:doctor_appointment_app/services/signal_r_service.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/view/components/Common/error_pop_up.dart';
import 'package:doctor_appointment_app/view/components/Common/loading.dart';
import 'package:doctor_appointment_app/view/pages/appointments_page.dart';
import 'package:doctor_appointment_app/view/pages/home_page.dart';
import 'package:doctor_appointment_app/view/pages/search_page.dart';
import 'package:doctor_appointment_app/view/pages/profile_page.dart';
import 'package:doctor_appointment_app/view_model/Appointment/appointments.dart';

import 'package:doctor_appointment_app/view_model/Patient/patient.dart';
import 'package:doctor_appointment_app/view_model/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(patientNotifier);
    final notifier = ref.read(patientNotifier.notifier);
    return patientAsync.when(
      data: (patient) {
        if (patient == null) {
          // If patient is null, it means either not logged in or token expired
          return Scaffold(
            body: Center(
              child:!notifier.isSessionExpired?const Loading(message: 'Signing out',): ErrorPopUp(
                title: 'Please sign in again',
                content: '',
                buttonText: 'Sign in',
                onOk: () async {
                  await ref.read(patientNotifier.notifier).logout();
                  Get.offAllNamed(Sroutes.auth);
                },
                cantGetBack: true,
              ),
            ),
          );
        }

        return SignalRConnectionWidget(
          patient: patient,
          child: _MainLayoutContent(patient: patient),
        );
      },
      loading: () => const Scaffold(body: Center(child: Loading())),
      error: (error, stackTrace) {
        // This should only handle non-401 errors now
        return Scaffold(
          body: Center(
            child: ErrorPopUp(
              title: 'Connection Error',
              content: 'Please check your connection and try again',
              buttonText: 'Retry',
              onOk: () {
                ref.invalidate(patientNotifier);
              },
            ),
          ),
        );
      },
    );
  }
}

class _MainLayoutContent extends StatefulWidget {
  final Patient patient;

  const _MainLayoutContent({required this.patient});

  @override
  State<_MainLayoutContent> createState() => __MainLayoutContentState();
}

class __MainLayoutContentState extends State<_MainLayoutContent> {
  int currentIndex = 0;
  final PageController _pageController = PageController();

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: <Widget>[
          HomePage(patient: widget.patient),
          const SearchPage(),
          const AppointmentPage(),
          ProfilePage(patient: widget.patient),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Config.primaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.houseChimneyMedical),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.search),
            label: AppLocalizations.of(context)!.search,
          ),
          BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.solidCalendarCheck),
            label: AppLocalizations.of(context)!.appointments,
          ),
          BottomNavigationBarItem(
            icon: const FaIcon(FontAwesomeIcons.solidUser),
            label: AppLocalizations.of(context)!.profile,
          ),
        ],
      ),
    );
  }
}

class SignalRConnectionWidget extends ConsumerStatefulWidget {
  final Widget child;
  final Patient patient;

  const SignalRConnectionWidget({
    super.key,
    required this.child,
    required this.patient,
  });

  @override
  ConsumerState<SignalRConnectionWidget> createState() =>
      _SignalRConnectionWidgetState();
}

class _SignalRConnectionWidgetState
    extends ConsumerState<SignalRConnectionWidget> {
  bool _isSignalRSetup = false;
  bool _isDisposed = false;
  StreamSubscription<bool>? _connectionSubscription;
  late Function(NotificationModel) _notificationCallback;
  late SignalRService _signalR; // Store reference

  @override
  void initState() {
    super.initState();

    // Store SignalR reference immediately
    _signalR = ref.read(signalRServiceProvider);

    // Create the callback
    _notificationCallback = (NotificationModel notification) {
      _handleIncomingNotification(notification);
    };

    LogService.i('🔄 SignalRConnectionWidget initState - Widget: $hashCode');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _setupSignalR();
      }
    });
  }

  Future<void> _setupSignalR() async {
    if (_isSignalRSetup || _isDisposed) {
      LogService.i(
        '⏭️ SignalR setup skipped - disposed: $_isDisposed, setup: $_isSignalRSetup',
      );
      return;
    }

    try {
      final token = LocalStorageService.getToken;
      final userId = LocalStorageService.getUserId;

      if (token == null || userId == null) {
        LogService.e('❌ Missing token or userId for SignalR');
        return;
      }

      LogService.i('🚀 Starting SignalR setup for widget: $hashCode');

      // Print current callback status for debugging
      _signalR.printCallbackStatus();

      // 1️⃣ Register notification callback
      _signalR.onReceiveNotification(_notificationCallback);

      // 2️⃣ Listen to connection changes
      _connectionSubscription = _signalR.connectionStream.listen((connected) {
        if (_isDisposed || !mounted) return;

        if (connected) {
          LogService.i('🔗 Connection established, joining group...');
          _joinUserGroup(userId);
        } else {
          LogService.i('🔌 Connection lost');
        }
      });

      // 3️⃣ Start connection only if not already connected
      if (!_signalR.isConnected) {
        LogService.i('🔌 Starting SignalR connection...');
        await _signalR.startConnection(token);
      } else {
        LogService.i('✅ SignalR already connected, just joining group');
        await _joinUserGroup(userId);
      }

      _isSignalRSetup = true;
      LogService.i('✅ SignalR setup completed for widget: $hashCode');

      // Print callback status after setup
      _signalR.printCallbackStatus();
    } catch (e) {
      if (!_isDisposed) {
        LogService.e('❌ SignalR setup failed for widget: $hashCode', e);
      }
    }
  }

  void _handleIncomingNotification(NotificationModel notification) async {
    // Triple safety check
    if (_isDisposed || !mounted) {
      LogService.w(
        '⚠️ Notification received but widget is disposed: ${notification.title}',
      );
      return;
    }

    LogService.i(
      '🎯 Processing notification immediately: ${notification.title}',
    );

    try {
      // Refresh providers immediately
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadCountProvider);
      ref.read(appointmentsProvider.notifier).status = null;
      await ref.read(appointmentsProvider.notifier).refresh();

      LogService.w('✅ Providers refreshed immediately');
      // _showNotificationPopup(notification);
    } catch (e) {
      LogService.e('❌ Error handling notification', e);
    }
  }

  Future<void> _joinUserGroup(String userId) async {
    if (_isDisposed) return;

    try {
      LogService.i('👤 Joining user group for: $userId');
      await _signalR.joinUserGroup(userId);

      if (!_isDisposed) {
        await Future.delayed(const Duration(seconds: 1));
        _signalR.printConnectionStatus();
      }
    } catch (e) {
      if (!_isDisposed) {
        LogService.e('❌ Failed to join user group', e);
      }
    }
  }

  void _showNotificationPopup(NotificationModel notification) {
    if (_isDisposed || !mounted) {
      LogService.w('⚠️ Cannot show popup - widget disposed');
      return;
    }

    try {
      LogService.i('📢 Showing notification popup: ${notification.title}');

      Get.snackbar(
        notification.title,
        notification.message,
        backgroundColor: Config.accentColor,
        colorText: Colors.white,
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
        icon: const Icon(Icons.notifications, color: Colors.white),
        shouldIconPulse: true,
      );

      LogService.i('✅ Notification shown successfully: ${notification.title}');
    } catch (e) {
      LogService.e('❌ Error showing notification popup', e);
    }
  }

  @override
  void dispose() {
    LogService.i('🔴 Disposing SignalRConnectionWidget: $hashCode');

    _isDisposed = true;

    // Cancel subscription first
    if (_connectionSubscription != null) {
      _connectionSubscription!.cancel();
      _connectionSubscription = null;
      LogService.i('📪 Connection subscription cancelled');
    }

    // Remove our specific callback from SignalR service
    try {
      _signalR.removeNotificationCallback(_notificationCallback);
      LogService.i('🗑️ Removed notification callback for widget: $hashCode');
      _signalR.printCallbackStatus(); // Debug print
    } catch (e) {
      LogService.e('❌ Error removing notification callback', e);
    }

    super.dispose();
    LogService.i('✅ SignalRConnectionWidget disposed: $hashCode');
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
