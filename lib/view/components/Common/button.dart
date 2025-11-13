import 'package:doctor_appointment_app/utils/config.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.width,
    required this.title,
    required this.disabled,
    required this.onPressed,
    this.height
  });
  final double width;
  final String title;
  final bool disabled;
  final Function() onPressed;
  final double?height;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Config.primaryColor,
          foregroundColor: Colors.white,
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadiusGeometry.all(Radius.circular(2)),
          ),
        ),
        onPressed: disabled ? null : onPressed,
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
