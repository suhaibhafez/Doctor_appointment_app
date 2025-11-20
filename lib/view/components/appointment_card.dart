import 'package:doctor_appointment_app/l10n/app_localizations.dart';

import 'package:doctor_appointment_app/utils/config.dart';

import 'package:flutter/material.dart';
import 'package:rating_dialog/rating_dialog.dart';


class AppointmentCard extends StatefulWidget {
  const AppointmentCard({super.key, required this.doctor, required this.color});
  final Map<String, dynamic> doctor;
  final Color color;
  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    
                    backgroundImage: AssetImage('assets/doctor_1.jpg'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppLocalizations.of(context)!.dr}${widget.doctor['doctor_name']}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        '${widget.doctor['category']}',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
              Config.spaceSmall,
              ScheduleCard(
                appointment: widget.doctor['appointments'],
              ),
              Config.spaceSmall,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: const BeveledRectangleBorder(
                          borderRadius: BorderRadiusGeometry.all(
                            Radius.circular(2),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return RatingDialog(
                              initialRating: 1.0,
                              title: const Text(
                                'Rate the Doctor',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              message: const Text(
                                'Please help us rate our Doctor',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              image: const FlutterLogo(
                                size: 100,
                              ),
                              submitButtonText: 'Submit',
                              commentHint: 'Your Reviews',
                              onSubmitted: (response) async {
                              },
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: const BeveledRectangleBorder(
                          borderRadius: BorderRadiusGeometry.all(
                            Radius.circular(2),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({super.key, required this.appointment});
  final Map<String, dynamic> appointment;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today,
            color: Colors.white,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            '${appointment['day']},${appointment['date']}',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(
            width: 20,
          ),
          const Icon(
            Icons.access_alarm,
            color: Colors.white,
            size: 17,
          ),
          const SizedBox(
            width: 5,
          ),
          Flexible(
            child: Text(
              appointment['time'],
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
