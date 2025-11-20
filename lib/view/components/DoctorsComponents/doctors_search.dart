import 'dart:async';

import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:doctor_appointment_app/view_model/Doctor/doctors.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/utils/enums/specialitiez_facilities.dart';
import 'package:doctor_appointment_app/view/components/Common/cool_button.dart';
import 'package:doctor_appointment_app/view/components/DoctorsComponents/doctor_card.dart';
import 'package:doctor_appointment_app/view/components/Common/error_pop_up.dart';
import 'package:doctor_appointment_app/view/components/Common/shimmer.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class DoctorSearch extends ConsumerStatefulWidget {
  const DoctorSearch({super.key});

  @override
  ConsumerState<DoctorSearch> createState() => DoctorSearchState();
}

class DoctorSearchState extends ConsumerState<DoctorSearch> {
  late final MenuController _menuController;
  late final TextEditingController _specializationController;
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _menuController = MenuController();
    _specializationController = TextEditingController(); // init empty
    _searchController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final specializationIndex = ref
        .read(doctorProvider(null).notifier)
        .specialization;

    if (specializationIndex != null) {
      final localizedText = getLocalizedSpe(
        Speciality.values[specializationIndex].name,
        context,
        false,
      );
      _specializationController.text = localizedText;
    }
  }

  @override
  void dispose() {
    _specializationController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specialitiesList = getSpecialitiesList(context);
    final doctorsState = ref.watch(doctorProvider(null));
    final notifier = ref.watch(doctorProvider(null).notifier);
    Config().init(context);

    return Column(
      children: [
        // 🔍 Search + Filter Row
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: TextFormField(
                controller: _searchController,
                onChanged: (value) {
                  _debounce?.cancel();
                  _debounce = Timer(
                    const Duration(milliseconds: 400),
                    () async => await notifier.updateSearch(value),
                  );
                },
                cursorColor: Config.primaryColor,
                decoration: InputDecoration(
                  hintText: '${AppLocalizations.of(context)!.search}...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: notifier.q != null
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () async {
                            _searchController.clear();
                            await notifier.updateSearch(null);
                          },
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: MenuAnchor(
                useRootOverlay: true,
                style: const MenuStyle(
                  maximumSize: WidgetStatePropertyAll(Size.fromHeight(250)),
                ),
                controller: _menuController,
                // ignore: sort_child_properties_last
                child: TextFormField(
                  onTap: () => _menuController.isOpen
                      ? _menuController.close()
                      : _menuController.open(),
                  readOnly: true,

                  controller: _specializationController,

                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.specialization,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        if (notifier.specialization != null)
                          IconButton(
                            onPressed: () async {
                              _specializationController.clear();
                              await notifier.updateSpecialization(null);
                            },
                            icon: const Icon(
                              Icons.close,
                            ),
                          ),
                        if (notifier.specialization == null)
                          IconButton(
                            icon: const Icon(Icons.arrow_drop_down),
                            onPressed: () {
                              if (_menuController.isOpen) {
                                _menuController.close();
                              } else {
                                _menuController.open();
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                menuChildren: Speciality.values.sublist(1).map((e) {
                  return MenuItemButton(
                    onPressed: () async {
                      _specializationController.text = getLocalizedSpe(
                        e.name,
                        context,
                        false,
                      );
                      await notifier.updateSpecialization(e.index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: 6,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            specialitiesList[e.index]['icon'],
                            color: Config.primaryColor,
                          ),

                          Text(specialitiesList[e.index]['category']),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),

        Config.spaceSmall,

        // 🩺 Doctor list with manual paging
        Expanded(
          child: RefreshIndicator.adaptive(
            onRefresh: () async {
              _searchController.clear();
              _specializationController.clear();
              await notifier.clearFilters();
            },
            child: doctorsState.when(
              data: (doctors) {
                return doctors.isEmpty
                    ? const Center(child: Text('No doctors found'))
                    : NotificationListener<ScrollNotification>(
                        onNotification: (scrollInfo) {
                          if (scrollInfo.metrics.pixels >=
                                  scrollInfo.metrics.maxScrollExtent - 200 &&
                              !notifier.isLoadingMore &&
                              !notifier.isLastPage &&
                              notifier.loadMoreError == null) {
                            notifier.loadMore();
                          }
                          return false;
                        },
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isSmall = constraints.maxWidth < 360;
                            return ListView.builder(
                              itemCount:
                                  doctors.length +
                                  (notifier.isLoadingMore ||
                                          notifier.isLastPage ||
                                          notifier.loadMoreError != null
                                      ? 1
                                      : 0),
                              itemBuilder: (context, index) {
                                if (index < doctors.length) {
                                  return DoctorCard(doctor: doctors[index]);
                                }

                                // This is the extra "footer" item
                                if (notifier.isLoadingMore) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                if (notifier.loadMoreError != null) {
                                  return CoolButton(
                                    isSmall: isSmall,
                                    onclick: () async =>
                                        await notifier.loadMore(),
                                    text: "اعادة المحاولة",
                                    icon: const Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                    ),
                                    alignment: Alignment.center,
                                  );
                                }
                                if (notifier.isLastPage) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10.0,
                                    ),
                                    child: Divider(
                                      color: Config.primaryColor,
                                      height: 2,
                                    ),
                                  );
                                }

                                return const SizedBox.shrink();
                              },
                            );
                          },
                        ),
                      );
              },
              loading: () => ListView.builder(
                itemCount: notifier.pageSize,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, _) => const ShimmerDoctorCard(),
              ),
              error: (err, _) => Center(
                child: ErrorPopUp(
                  title: 'Something went wrong',
                  content: err.toString(),
                  buttonText: 'Retry',
                  onOk: () async {
                    _specializationController.clear();
                    _searchController.clear();
                    await notifier.clearFilters();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
