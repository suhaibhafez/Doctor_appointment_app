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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,

      title: widget.appTitle != null
          ? Text(
              widget.appTitle!,
              style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            )
          : null,

      leading: widget.icon != null
          ? Container(
              margin: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
              child: Material(
                color: isDark ? Config.surfaceDark : Config.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                elevation: isDark ? 2 : 3,
                shadowColor: Colors.black26,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    await widget.onBack?.call();
                    Get.back();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      widget.icon!.icon,
                      size: 18,
                      color: isDark ? Config.accentColor : Config.primaryColor,
                    ),
                  ),
                ),
              ),
            )
          : null,

      actions: widget.actions?.map(
        (action) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 10,
            ),
            child: Material(
              color: isDark ? Config.surfaceDark : Config.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              elevation: isDark ? 2 : 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: action,
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}
