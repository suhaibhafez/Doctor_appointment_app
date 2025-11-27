import 'package:doctor_appointment_app/models/Patient/patient.dart';
import 'package:doctor_appointment_app/models/notification_model.dart';
import 'package:doctor_appointment_app/routes/routes.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/utils/enums/specialitiez_facilities.dart';
import 'package:doctor_appointment_app/view/components/AppointmentsComponents/appointment_card.dart';
import 'package:doctor_appointment_app/view/components/Common/cool_button.dart';
import 'package:doctor_appointment_app/view/components/Common/error_pop_up.dart';
import 'package:doctor_appointment_app/view/components/Common/shimmer.dart';
import 'package:doctor_appointment_app/view/components/DoctorsComponents/doctor_card.dart';
import 'package:doctor_appointment_app/view_model/Appointment/appointments_today.dart';
import 'package:doctor_appointment_app/view_model/Doctor/doctors.dart';

import 'package:doctor_appointment_app/view_model/notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends ConsumerWidget {
  final Patient patient;
  const HomePage({super.key, required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Config().init(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            spacing: 20,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo + App Name on the left
                  Row(
                    children: [
                      Transform.scale(
                        scale: 1.1,
                        child: Image.asset(
                          'assets/logo.png',
                          width: Config.screenWidth! * 0.12,
                          height: Config.screenWidth! * 0.12,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Shifa",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Config.textLight
                              : Config.textDark,
                          fontFamily: 'Poppins',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  // Patient info + Notification on the right
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Patient info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${patient.firstName} ${patient.lastName}',
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              patient.nationalId,
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        // Notification bell
                        const NotificationBell(),
                      ],
                    ),
                  ),
                ],
              ),

              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    // Handle infinite scrolling for doctors here
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 200) {
                      final notifier = ref.read(doctorProvider(null).notifier);
                      if (!notifier.isLoadingMore &&
                          !notifier.isLastPage &&
                          notifier.loadMoreError == null) {
                        notifier.loadMore();
                      }
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    slivers: [
                      // Today's Appointments
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today\'s Appointments',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const AppointmentsTodayList(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),

                      // Specialities Section
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explore Specialities',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(
                              height: 80,
                              child: SpecialitiesList(),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),

                      // Facilities Section
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explore Facilities',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(
                              height: 80,
                              child: FacilitiesList(),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),

                      // Top Doctors Section
                      SliverToBoxAdapter(
                        child: Text(
                          'Top Doctors',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),

                      // Doctors List as SliverList
                      Consumer(
                        builder: (context, ref, child) {
                          final doctorsState = ref.watch(doctorProvider(null));
                          return doctorsState.when(
                            data: (doctors) {
                              if (doctors.isEmpty) {
                                return const SliverToBoxAdapter(
                                  child: Center(
                                    child: Text('No doctors found'),
                                  ),
                                );
                              }

                              final notifier = ref.read(
                                doctorProvider(null).notifier,
                              );
                              return SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    if (index < doctors.length) {
                                      return DoctorCard(doctor: doctors[index]);
                                    }

                                    // Loading more indicator
                                    if (notifier.isLoadingMore) {
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(12),
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }

                                    // Error state
                                    if (notifier.loadMoreError != null) {
                                      return CoolButton(
                                        onclick: () async =>
                                            await notifier.loadMore(),
                                        text: "اعادة المحاولة",
                                        icon: const Icon(
                                          Icons.refresh,
                                          color: Colors.white,
                                        ),
                                        alignment: Alignment.center,
                                        isSmall:
                                            MediaQuery.of(context).size.width >
                                            360,
                                      );
                                    }

                                    // End of list
                                    if (notifier.isLastPage) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        child: Divider(
                                          color: Config.primaryColor,
                                          height: 2,
                                        ),
                                      );
                                    }

                                    return const SizedBox.shrink();
                                  },
                                  childCount:
                                      doctors.length +
                                      (notifier.isLoadingMore ||
                                              notifier.isLastPage ||
                                              notifier.loadMoreError != null
                                          ? 1
                                          : 0),
                                ),
                              );
                            },
                            loading: () => SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => const ShimmerDoctorCard(),
                                childCount: 10,
                              ),
                            ),
                            error: (err, _) => SliverToBoxAdapter(
                              child: Center(
                                child: ErrorPopUp(
                                  title: 'Something went wrong',
                                  content: err.toString(),
                                  buttonText: 'Retry',
                                  onOk: () async => await ref
                                      .read(doctorProvider(null).notifier)
                                      .refresh(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SpecialitiesList extends StatelessWidget {
  const SpecialitiesList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final specialities = getSpecialitiesList(
      context,
    ).sublist(1);
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,

      itemCount: specialities.length,
      itemBuilder: (context, index) {
        final speciality = specialities[index];
        return SpecialityItem(
          icon: speciality["icon"],
          category: speciality["category"],
          onTap: () async {
            await Get.toNamed(
              Sroutes.doctorsBySpecialityPage,
              arguments: index + 1,
            );
          },
        );
      },
    );
  }
}

class FacilitiesList extends StatelessWidget {
  const FacilitiesList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final facilities = getFacilityTypesList(
      context,
    );
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,

      itemCount: facilities.length,
      itemBuilder: (context, index) {
        final facilitiy = facilities[index];
        return SpecialityItem(
          icon: facilitiy["icon"],
          category: facilitiy["category"],
          onTap: () async {
            await Get.toNamed(
              Sroutes.facilitiesByTypePage,
              arguments: facilitiy['key'],
            );
          },
        );
      },
    );
  }
}

class AppointmentsTodayList extends ConsumerStatefulWidget {
  const AppointmentsTodayList({super.key});

  @override
  ConsumerState<AppointmentsTodayList> createState() =>
      _AppointmentsTodayListState();
}

class _AppointmentsTodayListState extends ConsumerState<AppointmentsTodayList> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    final appointmentsToday = ref.watch(appointmentstodayProvider);

    return appointmentsToday.when(
      data: (appointments) {
        if (appointments.isEmpty) {
          return const NoAppointmentsCard();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// IMPORTANT FIX:
            /// Wrap PageView in SizedBox   so height is determined by the CARD,
            /// not infinite page view.
            SizedBox(
              height: 315,
              child: PageView.builder(
                controller: _controller,
                physics: const BouncingScrollPhysics(),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  return AppointmentCard(
                    appointment: appointments[index],
                  );
                },
              ),
            ),
            if (appointments.length > 1) ...[
              const SizedBox(height: 12),

              SmoothPageIndicator(
                controller: _controller,
                count: appointments.length,
                effect: ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3,
                  activeDotColor: Theme.of(context).colorScheme.primary,
                  dotColor: Colors.grey.shade400,
                ),
              ),
            ],
          ],
        );
      },

      loading: () => const ShimmerAppointmentCard(),
      error: (error, _) => Center(child: Text("Error: $error")),
    );
  }
}

class SpecialityItem extends StatelessWidget {
  final IconData icon;
  final String category;
  final VoidCallback onTap;

  const SpecialityItem({
    super.key,
    required this.icon,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? Config.surfaceDark : Config.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Config.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                category,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Config.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoAppointmentsCard extends StatelessWidget {
  const NoAppointmentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey.shade300,
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            FontAwesomeIcons.solidCalendarCheck,
            size: 40,
            color: Config.primaryColor,
          ),
          const SizedBox(height: 12),
          Text(
            'No Appointments Today',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You’re all caught up for the day!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationBell extends ConsumerWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);

    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none, // Add this to prevent clipping
        children: [
          const Icon(
            Icons.notifications,
            color: Config.primaryColor,
            size: 30,
          ),
          unreadCount.maybeWhen(
            data: (value) => value > 0
                ? Positioned(
                    right: -2, // Adjusted for better positioning
                    top: -2, // Adjusted for better positioning
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent, // Fixed the color assignment
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        value > 99 ? '99+' : value.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : const SizedBox.shrink(), // Show nothing when count is 0
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      onPressed: () async {
        await Get.dialog(
          const Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(20),
            child: NotificationPanel(),
          ),
          barrierDismissible: false,
        );
      },
    );
  }
}

class NotificationPanel extends ConsumerWidget {
  const NotificationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Container(
      width: Config.screenWidth! * 0.9, // 90% of screen width
      height: Config.screenHeight! * 0.7, // 70% of screen height
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header - Using your theme colors
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Close button
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    ref.invalidate(unreadCountProvider);
                    Get.back();
                  },
                  tooltip: 'Close',
                ),
              ],
            ),
          ),

          // Notifications List
          Expanded(
            child: notificationsAsync.when(
              data: (notifications) {
                if (notifications.isEmpty) {
                  return Center(
                    child: Text(
                      'No notifications',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Mark all as read button - compact version
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextButton.icon(
                        onPressed: () async {
                          await ref
                              .read(notificationsProvider.notifier)
                              .markAllAsRead();
                        },
                        icon: Icon(
                          Icons.done_all,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: Text(
                          'Mark all as read',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),

                    // Notifications list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return Dismissible(
                            key: ValueKey(notification.id),
                            background: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(
                                  12,
                                ), // Matches your card
                              ),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              child: const Icon(
                                Icons.done_all,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            secondaryBackground: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(
                                  12,
                                ), // Matches your card
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.done_all,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            child: _NotificationItem(
                              notification: notification,
                            ),
                            onDismissed: (direction) async => await ref
                                .read(notificationsProvider.notifier)
                                .markAsRead(notification.id),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              error: (error, stack) => Center(
                child: ErrorPopUp(
                  title: 'Something went wrong',
                  content: error.toString(),
                  onOk: () => ref.invalidate(notificationsProvider),
                  cantGetBack: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationItem({
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final notificationColor = _getNotificationColor(context, notification.type);

    return Card(
      color: notificationColor.withOpacity(0.1),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notificationColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        title: Text(
          notification.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              // maxLines: 2,
              // overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),

        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Color _getNotificationColor(BuildContext context, String type) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (type.toUpperCase()) {
      case 'APPOINTMENT_CREATED':
        return colorScheme.primary; // Blue-teal
      case 'APPOINTMENT_CONFIRMED':
        return Colors.green; // Success green
      case 'APPOINTMENT_CANCELLED':
        return colorScheme.error; // Red for errors/cancellations
      case 'APPOINTMENT_COMPLETED':
        return Colors.teal; // Teal for completed
      case 'BILLING_CREATED':
        return Colors.orange; // Orange for billing
      case 'BILLING_PAID':
        return Colors.purple; // Purple for paid
      case 'REMINDER':
        return Colors.amber; // Amber for reminders
      case 'SYSTEM':
        return Colors.blueGrey; // Blue-grey for system
      default:
        return colorScheme.primary; // Default primary color
    }
  }

  // // Alternative version using only your theme colors:
  // Color _getNotificationColorAlt(BuildContext context, String type) {
  //   final colorScheme = Theme.of(context).colorScheme;

  //   switch (type.toUpperCase()) {
  //     case 'APPOINTMENT_CREATED':
  //       return colorScheme.primary; // Blue-teal
  //     case 'APPOINTMENT_CONFIRMED':
  //       return Config.accentColor; // Mint accent
  //     case 'APPOINTMENT_CANCELLED':
  //       return colorScheme.error; // Red
  //     case 'APPOINTMENT_COMPLETED':
  //       return Colors.green; // Green
  //     case 'BILLING_CREATED':
  //       return Colors.orange; // Orange
  //     case 'BILLING_PAID':
  //       return Colors.purple; // Purple
  //     case 'REMINDER':
  //       return Colors.amber; // Amber
  //     case 'SYSTEM':
  //       return Colors.blueGrey; // Blue-grey
  //     default:
  //       return colorScheme.primary;
  //   }
  // }

  // // Version using opacity variations of your primary color:
  // Color _getNotificationColorSimple(BuildContext context, String type) {
  //   final colorScheme = Theme.of(context).colorScheme;

  //   switch (type.toUpperCase()) {
  //     case 'APPOINTMENT_CREATED':
  //       return colorScheme.primary;
  //     case 'APPOINTMENT_CONFIRMED':
  //       return Colors.green;
  //     case 'APPOINTMENT_CANCELLED':
  //       return colorScheme.error;
  //     case 'APPOINTMENT_COMPLETED':
  //       return Config.accentColor;
  //     case 'BILLING_CREATED':
  //       return Colors.orange;
  //     case 'BILLING_PAID':
  //       return Colors.purple;
  //     case 'REMINDER':
  //       return Colors.amber;
  //     case 'SYSTEM':
  //       return colorScheme.primary.withOpacity(0.7);
  //     default:
  //       return colorScheme.primary;
  //   }
  // }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}
