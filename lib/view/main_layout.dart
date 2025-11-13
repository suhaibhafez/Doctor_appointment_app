import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:doctor_appointment_app/view/pages/appointments_page.dart';
import 'package:doctor_appointment_app/view/pages/home_page.dart';
import 'package:doctor_appointment_app/view/pages/search_page.dart';
import 'package:doctor_appointment_app/view/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 0;
  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

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
