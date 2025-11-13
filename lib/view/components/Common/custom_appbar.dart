import 'package:doctor_appointment_app/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/route_manager.dart';

class CustomAppbar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppbar({
    super.key,
    this.actions,
    this.appTitle,
    this.icon,
    this.onBack,
  });
  final String? appTitle;
  final Future<void> Function()? onBack;
  final FaIcon? icon;
  final List<Widget>? actions;
  @override
  Size get preferredSize => const Size.fromHeight(60);
  @override
  State<CustomAppbar> createState() => _CustomAppbarState();
}

class _CustomAppbarState extends State<CustomAppbar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      centerTitle: true,
      // backgroundColor: Colors.white,
      elevation: 0,
      title:widget.appTitle!=null? Text(
        widget.appTitle!,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
      ):null,
      leading: widget.icon != null
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Config.primaryColor,
              ),
              child: IconButton(
                onPressed: ()async {
                  await widget.onBack?.call();
                    Get.back();
                 
                },
                icon: widget.icon!,
                iconSize: 16,
                color: Colors.white,
              ),
            )
          : null,
      actions: widget.actions,
    );
  }
}
