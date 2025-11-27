import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:doctor_appointment_app/services/log_service.dart';
import 'package:doctor_appointment_app/services/signal_r_service.dart';

import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/view/pages/appointments_page.dart';
import 'package:doctor_appointment_app/view/pages/home_page.dart';
import 'package:doctor_appointment_app/view/pages/search_page.dart';
import 'package:doctor_appointment_app/view/pages/profile_page.dart';

import 'package:doctor_appointment_app/view_model/notification.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int currentIndex = 0;
  late SignalRService signalR;
  final PageController _pageController = PageController();
  void show({
    required BuildContext context,
    required String title,
    required String message,
    required DateTime createdAt,
  }) {
    Get.snackbar(
      "",
      "",
      titleText: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
      backgroundColor: Config.accentColor,
      borderRadius: 16,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      boxShadows: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _setupSignalR();
  }

  void _setupSignalR() {
    signalR = ref.read(signalRServiceProvider);



    if (signalR.isConnected) {
      LogService.i('SignalR already connected');

      return;
    }
  

    LogService.i('SignalR connection started from main');

    signalR.onReceiveNotification((notification) {
     
      ref.read(notificationsProvider.notifier).addNotification(notification);
      ref.invalidate(unreadCountProvider);
      show(
        context: Get.context!,
        title: notification.title,
        message: notification.message,
        createdAt: notification.createdAt,
      );
    });

    signalR.startConnection().then((_) {
      signalR.joinUserGroup("d84f26a0-9327-41f6-932d-47dc1e0fa5d1");
    });
  }

  @override
  void dispose() {
    signalR.stopConnection();
    // Only stop if you're sure the app is closing
    // ref.read(signalRServiceProvider).stopConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (value) {
          setState(() {
            currentIndex = value;
          });
        },
        children: const <Widget>[
          // HomePage(),
          HomePage(),
          SearchPage(),
          AppointmentPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (value) {
          setState(() {
            currentIndex = value;
            _pageController.animateToPage(
              value,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          });
        },
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
