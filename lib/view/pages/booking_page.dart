// Required imports
import 'package:doctor_appointment_app/models/Doctor/doctor_capacity.dart';
import 'package:doctor_appointment_app/models/Doctor/doctor_exception_schedule.dart';
import 'package:doctor_appointment_app/models/Doctor/doctor_schedule.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/view/components/Common/button.dart';
import 'package:doctor_appointment_app/view/components/Common/custom_appbar.dart';
import 'package:doctor_appointment_app/view_model/Appointment/appointments.dart';
import 'package:doctor_appointment_app/view_model/Doctor/doctor_capacity.dart';
import 'package:doctor_appointment_app/view_model/Doctor/doctor_schedule.dart';
import 'package:doctor_appointment_app/view_model/Doctor/doctor_schedule_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  DateTime _focusDay = DateTime.now();
  DateTime _currentDay = DateTime.now();
 
  late bool _dateSelected;
  bool _timeSelected = false;

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
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _tableCalendar(),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 25,
                      ),
                      child: Center(
                        child: Text(
                          'Select Consultion Time',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
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
                          child:  Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      // If any provider has error
                      if (scheduleAsync.hasError ||
                          exceptionAsync.hasError ||
                          capacityAsync.hasError) {
                        return const SizedBox(
                          height: 180,
                          child: Center(
                            child: Text(
                              'Failed to load schedule. Try again.',
                              style: TextStyle(color: Config.errorColor),
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
                        child:  _availableSlots.isEmpty
                            ? const Center(
                                child: Text(
                                  'Weekend is not available',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : _buildSlotsGrid(),
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Button(
                    width: double.infinity,
                    title: 'Make Appointment',
                    disabled: !(_timeSelected && _dateSelected),
                    onPressed: () async {
                      if (_selectedSlot == null) return;

                      // Format date and time to expected API format
                      final scheduleDate = _formatDateOnly(_selectedSlot!);
                      final scheduleTime = _formatTimeOnly(_selectedSlot!);

                      // Call your AsyncNotifier (adjust provider name if different)
                      try {
                        print('Booking appointment on $scheduleDate at $scheduleTime');
                        await ref
                            .read(appointmentsProvider.notifier)
                            .addAppointment(
                              docId,
                              facId,
                              scheduleDate,
                              scheduleTime,
                              ref.read(
                                doctorCapacityProvider(docId)
                              ).maybeWhen(
                                  data: (value) => value.sessionDurationMinutes,
                                  orElse: () => 30,
                                ),
                            );

                        // success UI
                        if (mounted) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Success'),
                              content: const Text(
                                'Appointment booked successfully.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop(); // go back
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      } catch (e) {
                        // handle error
                        if (mounted) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Error'),
                              content: Text('Failed to book appointment: $e'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
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
      return const Center(
        child: Text(
          'No available slots',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
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
                color: isSelected ? Colors.white : Colors.black,
              ),
              borderRadius: BorderRadius.circular(15),
              color: isSelected ? Config.primaryColor : null,
            ),
            alignment: Alignment.center,
            child: Text(
              _formatSlotLabel(slot),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : null,
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
      firstDay: DateTime.now(),
      lastDay: DateTime(2025, 12, 31),
      calendarFormat: _format,
      currentDay: _currentDay,
      rowHeight: 48,
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Config.primaryColor,
          shape: BoxShape.circle,
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
        capacity?.maxPatientsPerday ?? 999,
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

    // 5) Generate slots from finalSegments then apply capacity limit and remove already-booked (TODO)
    final allSlots = _generateSlotsFromSegments(
      finalSegments,
      capacity?.sessionDurationMinutes ?? 30,
      capacity?.maxPatientsPerday ?? 999,
    );

    // TODO: If you have a provider that returns existing appointments for doctor/date,
    // filter out those times here by checking equality (or overlapping) with allSlots.
    // e.g. finalSlots = allSlots.where((slot) => !bookedTimes.contains(slot)).toList();

    return allSlots;
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
    int maxPatientsPerDay,
  ) {
    final List<DateTime> slots = [];
    for (final seg in segments) {
      DateTime cursor = seg.start;
      while (!cursor.isAfter(
        seg.end.subtract(Duration(minutes: sessionMinutes)),
      )) {
        slots.add(cursor);
        cursor = cursor.add(Duration(minutes: sessionMinutes));
        if (slots.length >= maxPatientsPerDay) break;
      }
      if (slots.length >= maxPatientsPerDay) break;
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
