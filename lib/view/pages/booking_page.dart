// Required imports
import 'package:doctor_appointment_app/models/Doctor/doctor_capacity.dart';
import 'package:doctor_appointment_app/models/Doctor/doctor_exception_schedule.dart';
import 'package:doctor_appointment_app/models/Doctor/doctor_schedule.dart';
import 'package:doctor_appointment_app/routes/routes.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/view/components/Common/button.dart';
import 'package:doctor_appointment_app/view/components/Common/custom_appbar.dart';
import 'package:doctor_appointment_app/view/components/Common/error_pop_up.dart';
import 'package:doctor_appointment_app/view/components/Common/loading.dart';

import 'package:doctor_appointment_app/view_model/Appointment/appointments.dart';
import 'package:doctor_appointment_app/view_model/Doctor/doctor_capacity.dart';
import 'package:doctor_appointment_app/view_model/Doctor/doctor_schedule.dart';
import 'package:doctor_appointment_app/view_model/Doctor/doctor_schedule_exception.dart';
import 'package:doctor_appointment_app/view_model/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get/route_manager.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart'; // optional but nice; if not available use manual formatting

// Make sure intl is in pubspec or remove DateFormat usage and use manual formatting below.
class BookingPage extends ConsumerStatefulWidget {
  const BookingPage({super.key});

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusDay = DateTime.now().add(const Duration(days: 1));
  DateTime _currentDay = DateTime.now().add(const Duration(days: 1));

  late bool _dateSelected;
  bool _timeSelected = false;
  bool _isBooking = false;
  // List of generated available slots for the selected date (DateTime objects)
  List<DateTime> _availableSlots = [];

  // selected slot/time
  DateTime? _selectedSlot;

  final String docId = Get.parameters['docId'] ?? '';
  final String facId = Get.parameters['facId'] ?? '';

  @override
  void initState() {
    _dateSelected = true;
    super.initState();
    // initial compute may be done when build runs and providers are available
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);

    final scheduleAsync = ref.watch(doctorScheduleProvider(docId));
    final exceptionAsync = ref.watch(doctorScheduleExceptionProvider(docId));
    final capacityAsync = ref.watch(doctorCapacityProvider(docId));

    return Scaffold(
      appBar: const CustomAppbar(
        appTitle: 'Appointment',
        icon: FaIcon(Icons.arrow_back_ios),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _tableCalendar(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 25,
                            ),
                            child: Center(
                              child: Text(
                                'Select Consultation Time',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Config.textLight
                                      : Config.textDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Loading/error handling for providers and compute slots
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Builder(
                          builder: (context) {
                            // If any provider is loading, show loader
                            if (scheduleAsync is AsyncLoading ||
                                exceptionAsync is AsyncLoading ||
                                capacityAsync is AsyncLoading) {
                              return const SizedBox(
                                height: 180,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            // If any provider has error
                            if (scheduleAsync.hasError) {
                              return const SizedBox(
                                height: 180,
                                child: Center(
                                  child: Text(
                                    'Failed to load schedule. Please try again.',
                                    style: TextStyle(color: Config.errorColor),
                                  ),
                                ),
                              );
                            }

                            if (exceptionAsync.hasError) {
                              return const SizedBox(
                                height: 180,
                                child: Center(
                                  child: Text(
                                    'Failed to load exceptions. Please try again.',
                                    style: TextStyle(color: Config.errorColor),
                                  ),
                                ),
                              );
                            }

                            if (capacityAsync.hasError) {
                              return SizedBox(
                                height: 180,
                                child: Center(
                                  child: Text(
                                    capacityAsync.error.toString(),
                                    style: const TextStyle(
                                      color: Config.errorColor,
                                    ),
                                  ),
                                ),
                              );
                            }

                            // All data available
                            final List<DoctorSchedule> schedules =
                                scheduleAsync.value ?? [];
                            final List<DoctorExceptionSchedule> exceptions =
                                exceptionAsync.value ?? [];
                            final capacity = capacityAsync.value;

                            // compute available slots for the currently selected date
                            _availableSlots = _computeAvailableSlotsForDate(
                              selectedDate: _currentDay,
                              schedules: schedules,
                              exceptions: exceptions,
                              capacity: capacity,
                            );

                            // If weekend and no schedule/exception -> mark unavailable

                            // Grid or message
                            return SizedBox(
                              height: 180,
                              child: _buildSlotsGrid(),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Button(
                height: 48,
                width: double.infinity,
                title: 'Make Appointment',
                disabled: !(_timeSelected && _dateSelected) || _isBooking,
                onPressed: () async {
                  if (_selectedSlot == null) return;

                  // Format date and time to expected API format
                  final scheduleDate = _formatDateOnly(_selectedSlot!);
                  final scheduleTime = _formatTimeOnly(_selectedSlot!);
                  final appointmentsNotifier = ref.read(
                    appointmentsProvider.notifier,
                  );
                  setState(() {
                    _isBooking = true;
                  });
                  // Call your AsyncNotifier (adjust provider name if different)
                  await Get.showOverlay(
                    asyncFunction: () async =>
                        await appointmentsNotifier.addAppointment(
                          docId,
                          facId,
                          scheduleDate,
                          scheduleTime,
                          capacityAsync.value!.sessionDurationMinutes,
                        ),

                    loadingWidget: const Loading(),
                  );
                  setState(() {
                    _isBooking = false;
                  });
                  final error = appointmentsNotifier.addingAppointmentError;
                  if (error != null) {
                    await Get.dialog(
                      ErrorPopUp(
                        title: 'Something went wrong',
                        content: error.toString(),
                      ),
                    );
                  } else {
                    await Get.toNamed(Sroutes.successBooking);
                  }

                  // success UI

                  // handle error
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- UI helper: grid ----------
  Widget _buildSlotsGrid() {
    final slots = _availableSlots;
    if (slots.isEmpty) {
      return Center(
        child: Text(
          'No available slots',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).brightness == Brightness.dark
                ? Config.textLight.withOpacity(0.7)
                : Colors.grey,
          ),
        ),
      );
    }
    debugPrint(slots.length.toString());
    return GridView.builder(
      // physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(5),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.5,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isSelected = _selectedSlot != null && _selectedSlot == slot;
        return InkWell(
          overlayColor: const MaterialStatePropertyAll(Colors.transparent),
          onTap: () {
            setState(() {
              _selectedSlot = slot;
              _timeSelected = true;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).brightness == Brightness.dark
                    ? Config.textLight.withOpacity(0.4)
                    : Colors.black54,
                width: 1.3,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? Config.primaryColor
                  : Theme.of(context).brightness == Brightness.dark
                  ? Config.surfaceDark
                  : Config.surfaceLight,
              boxShadow: [
                if (!isSelected)
                  const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              _formatSlotLabel(slot),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).brightness == Brightness.dark
                    ? Config.textLight
                    : Config.textDark,
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------- Calendar widget ----------
  Widget _tableCalendar() {
    return TableCalendar(
      focusedDay: _focusDay,

      firstDay: DateTime.now().add(const Duration(days: 1)),
      lastDay: DateTime(2025, 12, 31),
      locale: ref
          .watch(settingsProvider)
          .maybeWhen(
            data: (settings) {
              final lang = settings['lang'];
              return lang;
            },
            orElse: () => 'en',
          ),
      startingDayOfWeek: StartingDayOfWeek.saturday,

      calendarFormat: _format,
      currentDay: _currentDay,
      rowHeight: 48,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        disabledTextStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Config.textLight.withOpacity(0.3)
              : Colors.grey.withOpacity(0.5),
        ),
        todayDecoration: const BoxDecoration(
          color: Config.primaryColor,
          shape: BoxShape.circle,
        ),

        selectedDecoration: const BoxDecoration(
          color: Config.accentColor,
          shape: BoxShape.circle,
        ),

        defaultTextStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Config.textLight
              : Config.textDark,
          fontWeight: FontWeight.bold,
        ),

        weekendTextStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Config.textLight
              : Config.textDark,
          fontWeight: FontWeight.bold,
        ),
      ),

      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Config.primaryColor,
        ),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: Config.primaryColor,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: Config.primaryColor,
        ),
      ),

      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Config.textLight
              : Config.textDark,
          fontWeight: FontWeight.bold,
        ),
        weekendStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Config.textLight
              : Config.textDark,
          fontWeight: FontWeight.bold,
        ),
      ),
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      onFormatChanged: (format) {
        setState(() {
          _format = format;
        });
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _currentDay = selectedDay;
          _focusDay = focusedDay;
          _dateSelected = true;

          // clear previously chosen time
          _selectedSlot = null;
          _timeSelected = false;
        });
      },
    );
  }

  // ---------- Core logic: compute slots ----------
  List<DateTime> _computeAvailableSlotsForDate({
    required DateTime selectedDate,
    required List<DoctorSchedule> schedules,
    required List<DoctorExceptionSchedule> exceptions,
    required DoctorCapacity? capacity,
  }) {
    // 1) find weekly schedule segment(s) for this day of week
    final weekdayName = _weekdayName(selectedDate.weekday); // "Tuesday", etc.
    final List<_TimeSegment> baseSegments = [];

    for (final s in schedules) {
      if (s.dayOfWeek.toLowerCase() == weekdayName.toLowerCase()) {
        final start = _combineDateWithTime(selectedDate, s.startTime);
        final end = _combineDateWithTime(selectedDate, s.endTime);
        if (end.isAfter(start)) baseSegments.add(_TimeSegment(start, end));
      }
    }

    // 2) find ACTIVE exceptions for this exact date
    final List<DoctorExceptionSchedule> activeExceptions = exceptions.where((
      e,
    ) {
      return e.status.toLowerCase() == 'active' &&
          _isSameDate(e.date, selectedDate);
    }).toList();

    // If there are no base segments but there are active exceptions that add availability (doctor works on normally-off day),
    // treat each exception as an available segment.
    if (baseSegments.isEmpty && activeExceptions.isNotEmpty) {
      final List<_TimeSegment> exSegments = [];
      for (final ex in activeExceptions) {
        final s = _combineDateWithTime(selectedDate, ex.startTime);
        final e = _combineDateWithTime(selectedDate, ex.endTime);
        if (e.isAfter(s)) exSegments.add(_TimeSegment(s, e));
      }
      // Use exception segments directly (they add availability)
      return _generateSlotsFromSegments(
        exSegments,
        capacity?.sessionDurationMinutes ?? 30,
        // capacity?.maxPatientsPerday ?? 999,
      );
    }

    // 3) If there are base segments and active exceptions, subtract exceptions (partial block)
    List<_TimeSegment> finalSegments = List.from(baseSegments);

    for (final ex in activeExceptions) {
      final exStart = _combineDateWithTime(selectedDate, ex.startTime);
      final exEnd = _combineDateWithTime(selectedDate, ex.endTime);
      finalSegments = _subtractSegmentList(
        finalSegments,
        _TimeSegment(exStart, exEnd),
      );
    }

    // 4) If finalSegments empty => no availability
    if (finalSegments.isEmpty) return [];
    debugPrint(finalSegments.length.toString());
    // 5) Generate slots from finalSegments
    final allSlots = _generateSlotsFromSegments(
      finalSegments,
      capacity?.sessionDurationMinutes ?? 30,
    );

    // NEW RULE: block slots that are less than 24 hours from now
    final now = DateTime.now();
    final List<DateTime> futureSlots = allSlots.where((slot) {
      final diff = slot.difference(now).inHours;
      return diff >= 24; // must be at least 24 hours ahead
    }).toList();

    return futureSlots;
  }

  // ---------- Helper functions ----------

  // Combine selected date with a time string like "08:00:00" -> DateTime on selectedDate
  DateTime _combineDateWithTime(DateTime date, String timeStr) {
    // Expect "HH:mm:ss" or "HH:mm"
    final parts = timeStr.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  // Generate slots for each segment and apply capacity
  List<DateTime> _generateSlotsFromSegments(
    List<_TimeSegment> segments,
    int sessionMinutes,
    // int maxPatientsPerDay,
  ) {
    final List<DateTime> slots = [];
    for (final seg in segments) {
      DateTime cursor = seg.start;
      while (!cursor.isAfter(
        seg.end.subtract(Duration(minutes: sessionMinutes)),
      )) {
        slots.add(cursor);
        cursor = cursor.add(Duration(minutes: sessionMinutes));
        // if (slots.length >= maxPatientsPerDay) break;
      }
      // if (slots.length >= maxPatientsPerDay) break;
    }
    return slots;
  }

  // Subtract a single block (removeBlock) from list of segments
  List<_TimeSegment> _subtractSegmentList(
    List<_TimeSegment> segments,
    _TimeSegment removeBlock,
  ) {
    final List<_TimeSegment> result = [];

    for (final seg in segments) {
      // No overlap
      if (removeBlock.end.isBefore(seg.start) ||
          removeBlock.start.isAfter(seg.end)) {
        result.add(seg);
        continue;
      }

      // removeBlock fully covers seg -> seg removed
      if (!removeBlock.start.isAfter(seg.start) &&
          !removeBlock.end.isBefore(seg.end)) {
        // whole segment removed
        continue;
      }

      // removeBlock is inside seg -> split into two
      if (removeBlock.start.isAfter(seg.start) &&
          removeBlock.end.isBefore(seg.end)) {
        result.add(_TimeSegment(seg.start, removeBlock.start));
        result.add(_TimeSegment(removeBlock.end, seg.end));
        continue;
      }

      // removeBlock overlaps start of seg
      if (!removeBlock.start.isAfter(seg.start) &&
          removeBlock.end.isAfter(seg.start) &&
          removeBlock.end.isBefore(seg.end)) {
        result.add(_TimeSegment(removeBlock.end, seg.end));
        continue;
      }

      // removeBlock overlaps end of seg
      if (removeBlock.start.isAfter(seg.start) &&
          removeBlock.start.isBefore(seg.end) &&
          !removeBlock.end.isBefore(seg.end)) {
        result.add(_TimeSegment(seg.start, removeBlock.start));
        continue;
      }
    }

    // sort result by start time
    result.sort((a, b) => a.start.compareTo(b.start));
    return result;
  }

  // Weekday name e.g., 2 -> "Tuesday"
  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Format slot for display like "08:00 AM"
  String _formatSlotLabel(DateTime dt) {
    try {
      return DateFormat.jm().format(dt);
    } catch (_) {
      // fallback if intl is not available
      final hour = dt.hour;
      final minute = dt.minute.toString().padLeft(2, '0');
      final ampm = hour >= 12 ? 'PM' : 'AM';
      final h12 = (hour % 12 == 0) ? 12 : hour % 12;
      return '$h12:$minute $ampm';
    }
  }

  // Format for API date "yyyy-MM-dd"
  String _formatDateOnly(DateTime dt) {
    try {
      return DateFormat('yyyy-MM-dd').format(dt);
    } catch (_) {
      return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    }
  }

  // Format for API time "HH:mm:ss"
  String _formatTimeOnly(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final ss = dt.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }
}

// small private helper class for time segments
class _TimeSegment {
  final DateTime start;
  final DateTime end;
  _TimeSegment(this.start, this.end);
}
