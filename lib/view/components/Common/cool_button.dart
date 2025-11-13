import 'package:doctor_appointment_app/utils/config.dart';
import 'package:flutter/material.dart';

class CoolButton extends StatelessWidget {
  const CoolButton({
    super.key,
    required this.isSmall,
    required this.onclick,
    required this.text,
    this.icon,
    this.alignment = Alignment.bottomRight,
    this.backgroundColor = Config.primaryColor,
    this.forGroundColor = Colors.white,
    this.borderColor,
  });
  final String text;
  final bool isSmall;
  final Widget? icon;
  final void Function()? onclick;
  final Alignment alignment;
  final Color backgroundColor;
  final Color forGroundColor;
  final Color? borderColor;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: icon,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: forGroundColor,
        shadowColor: borderColor ?? Config.primaryColor,
        overlayColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: borderColor == null
              ? BorderSide.none
              : BorderSide(color: borderColor!),
        ),
        elevation: 3,
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 24,
          vertical: isSmall ? 10 : 16,
        ),
      ),
      onPressed: onclick,
      label: FittedBox(
        child: Text(
          text,
          style: TextStyle(
            fontSize: isSmall ? 14 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
