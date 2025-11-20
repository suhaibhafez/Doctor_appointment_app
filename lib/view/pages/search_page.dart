import 'package:doctor_appointment_app/view/components/DoctorsComponents/doctors_search.dart';
import 'package:doctor_appointment_app/view/components/FacilitiesComponents/facilities_search.dart';
import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:flutter/material.dart';

// import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
Widget buildCustomTab(
  BuildContext context,
  int controllerIndex, {
  required int index,
  required String label,
}) {
  final bool isSelected = controllerIndex == index;
  final Color primary = Config.primaryColor;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeInOut,
    width: 110,
    height: 40,
    decoration: BoxDecoration(
      color: isSelected ? primary : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isSelected ? primary : Colors.grey.shade400,
        width: 1.2,
      ),
      boxShadow: isSelected
          ? [
              BoxShadow(
                color: primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : [],
    ),
    child: Center(
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: !isDark
              ? (isSelected ? Colors.white : Colors.black87)
              : (isSelected ? Colors.black87 : Colors.white),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    ),
  );
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPage();
}

class _SearchPage extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Config.spaceSmall,
              TabBar(
                onTap: (value) {
                  setState(() {
                    _tabController.animateTo(
                      value,
                      duration: const Duration(milliseconds: 400),
                    );
                  });
                },

                controller: _tabController,
                // unselectedLabelColor: Colors.black,
                // labelColor: Colors.black,
                dividerColor: Colors.transparent,
                indicatorColor: Colors.transparent,

                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                tabs: [
                  buildCustomTab(
                    context,
                    _tabController.index,
                    index: 0,
                    label: AppLocalizations.of(context)!.doctors,
                  ),
                  buildCustomTab(
                    context,
                    _tabController.index,
                    index: 1,
                    label: AppLocalizations.of(context)!.facilities,
                  ),
                ],
              ),
              Config.spaceMedium,

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [DoctorSearch(), FacilitySearch()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
