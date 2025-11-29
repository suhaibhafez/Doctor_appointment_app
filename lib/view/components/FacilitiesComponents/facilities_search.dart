import 'dart:async';

import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:doctor_appointment_app/view_model/Facility/facilities.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/utils/enums/specialitiez_facilities.dart';
import 'package:doctor_appointment_app/view/components/Common/cool_button.dart';
import 'package:doctor_appointment_app/view/components/Common/error_pop_up.dart';
import 'package:doctor_appointment_app/view/components/FacilitiesComponents/facility_card.dart';
import 'package:doctor_appointment_app/view/components/Common/shimmer.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class FacilitySearch extends ConsumerStatefulWidget {
  const FacilitySearch({super.key});

  @override
  ConsumerState<FacilitySearch> createState() => FacilitySearchState();
}

class FacilitySearchState extends ConsumerState<FacilitySearch> {
  late final MenuController _menuController;

  late final TextEditingController _typeController;
  late final TextEditingController _searchController;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _menuController = MenuController();
    _typeController = TextEditingController();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _typeController.dispose();
    _searchController.dispose();

    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final facilitiestypeList = getFacilityTypesList(context);
    Config().init(context);

    final facilitiesState = ref.watch(facilitiesProvider(null));
    final notifier = ref.watch(facilitiesProvider(null).notifier);

    return Column(
      children: [
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: TextFormField(
                controller: _searchController,
                onChanged: (value) async {
                  _debounce?.cancel();
                  _debounce = Timer(
                    const Duration(milliseconds: 400),
                    () async {
                      await notifier.updateSearch(value);
                    },
                  );
                },
                cursorColor: Config.primaryColor,
                decoration: InputDecoration(
                  hintText: '${AppLocalizations.of(context)!.search}...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: notifier.q != null
                      ? IconButton(
                          onPressed: () async {
                            _searchController.clear();
                            await notifier.updateSearch(null);
                          },
                          icon: const Icon(Icons.close),
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: MenuAnchor(
                controller: _menuController,

                useRootOverlay: true,
                style: const MenuStyle(
                  maximumSize: WidgetStatePropertyAll(Size.fromHeight(250)),
                ),
                builder: (context, controller, child) {
                  return TextFormField(
                    onTap: () {
                      if (_menuController.isOpen) {
                        controller.close();
                      } else {
                        _menuController.open();
                      }
                    },
                    readOnly: true,
                    controller: _typeController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.type,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (notifier.type != null)
                            IconButton(
                              onPressed: () async {
                                _typeController.clear();

                                await notifier.updateType(null);
                              },
                              icon: const Icon(Icons.close),
                            ),
                          if (notifier.type == null)
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
                  );
                },
                menuChildren: facilitiestypeList.map((e) {
                  return MenuItemButton(
                    onPressed: () async {
                      _typeController.text = e['category'];

                      await notifier.updateType(
                        e['key'],
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: 6,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            e['icon'],
                            color: Config.primaryColor,
                          ),
                          Text(e['category']),
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
        Expanded(
          child: RefreshIndicator.adaptive(
            onRefresh: () async {
              _typeController.clear();
              _searchController.clear();

              await notifier.clearFilters();
            },
            child: facilitiesState.when(
              data: (facilities) {
                return facilities.isEmpty
                    ? const Center(child: Text('No Facilities found'))
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
                            final isSmall = constraints.maxHeight < 360;
                            return ListView.builder(
                              itemCount:
                                  facilities.length +
                                  (notifier.isLoadingMore ||
                                          notifier.isLastPage ||
                                          notifier.loadMoreError != null
                                      ? 1
                                      : 0),
                              itemBuilder: (context, index) {
                                if (index < facilities.length) {
                                  return FacilityCard(
                                    facility: facilities[index],
                                  );
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
                    _typeController.clear();
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
