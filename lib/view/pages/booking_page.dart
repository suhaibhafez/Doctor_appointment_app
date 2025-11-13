import 'package:doctor_appointment_app/view/components/Common/button.dart';
import 'package:doctor_appointment_app/view/components/Common/custom_appbar.dart';

import 'package:doctor_appointment_app/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:table_calendar/table_calendar.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusDay = DateTime.now();
  DateTime _currentDay = DateTime.now();
  int? _currentIndex;
  bool _isWeekend = false;
  late bool _dateSelected;
  bool _timeSelected = false;


  @override
  void initState() {
   
    _dateSelected = _currentDay.day != 6 || _currentDay.day != 7 ? true : false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: const CustomAppbar(
        appTitle: 'Appointment',
        icon: FaIcon(Icons.arrow_back_ios),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Theme(
            data: Theme.of(context).copyWith(
              scrollbarTheme: const ScrollbarThemeData(
                thumbColor: WidgetStatePropertyAll(Colors.transparent),
              ),
            ),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _tableCalendar(),
                      const Padding(
                        padding: EdgeInsetsGeometry.symmetric(
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
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 180, // ✅ fixed height for both states
                    child: _isWeekend
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
                        : GridView.builder(
                            physics:
                                const NeverScrollableScrollPhysics(), // disable nested scroll
                            padding: const EdgeInsets.all(5),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 1.5,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 5,
                                ),
                            itemCount: 8,
                            itemBuilder: (context, index) {
                              return InkWell(
                                overlayColor: const WidgetStatePropertyAll(
                                  Colors.transparent,
                                ),
                                splashColor: Colors.transparent,
                                onTap: () {
                                  setState(() {
                                    _currentIndex = index;
                                    _timeSelected = true;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: _currentIndex == index
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    color: _currentIndex == index
                                        ? Config.primaryColor
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${index + 9}:00 ${index + 9 > 11 ? 'PM' : 'AM'}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _currentIndex == index
                                          ? Colors.white
                                          : null,
                                    ),
                                  ),
                                ),
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
                      disabled: _timeSelected && _dateSelected ? false : true,
                      onPressed: () async {
                       

                       
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
          if (selectedDay.weekday == 6 || selectedDay.weekday == 7) {
            _isWeekend = true;
            _timeSelected = false;
            _currentIndex = null;
          } else {
            _isWeekend = false;
          }
        });
      },
    );
  }
}
