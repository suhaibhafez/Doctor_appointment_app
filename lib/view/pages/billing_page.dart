import 'package:doctor_appointment_app/l10n/app_localizations.dart';
import 'package:doctor_appointment_app/models/Patient/billing.dart';
import 'package:doctor_appointment_app/utils/config.dart';
import 'package:doctor_appointment_app/view/components/Common/cool_button.dart';
import 'package:doctor_appointment_app/view/components/Common/custom_appbar.dart';
import 'package:doctor_appointment_app/view/components/Common/error_pop_up.dart';
import 'package:doctor_appointment_app/view/components/Common/shimmer.dart';
import 'package:doctor_appointment_app/view_model/Patient/biilings.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BillingPage extends ConsumerWidget {
  const BillingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billingsState = ref.watch(billingsProvider);
    final notifier = ref.watch(billingsProvider.notifier);
    Config().init(context);
    return Scaffold(
      appBar: CustomAppbar(
        appTitle: AppLocalizations.of(context)!.billings,

        icon: const FaIcon(Icons.arrow_back_ios),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: RefreshIndicator.adaptive(
            onRefresh: () async {
              await notifier.refresh();
            },
            child: billingsState.when(
              data: (billings) {
                return billings.isEmpty
                    ? const Center(child: Text('No Billings found'))
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
                            final isSmall = constraints.maxWidth < 360;
                            return ListView.builder(
                              itemCount:
                                  billings.length +
                                  (notifier.isLoadingMore ||
                                          notifier.isLastPage ||
                                          notifier.loadMoreError != null
                                      ? 1
                                      : 0),
                              itemBuilder: (context, index) {
                                if (index < billings.length) {
                                  return BillingCard(
                                    billing: billings[index],
                                  ); //replace with your card
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
                                    text: AppLocalizations.of(context)!.retry,
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
              loading: () => const AppointmentDetailsShimmer(),
              error: (err, _) => Center(
                child: ErrorPopUp(
                  title: 'Something went wrong',
                  content: err.toString(),
                  buttonText: AppLocalizations.of(context)!.retry,
                  onOk: () async {
                    await notifier.refresh();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BillingCard extends StatelessWidget {
  final Billing billing;

  const BillingCard({super.key, required this.billing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final t = AppLocalizations.of(context)!;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Config.primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧾 Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.localeName == 'en' ? 'Billing Summary' : 'ملخص الفاتورة',
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Config.primaryColor,
                  ),
                ),
                Text(
                  '#${billing.id.substring(0, 6).toUpperCase()}',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Divider(
              thickness: 1,
              color: isDark
                  ? Colors.white10
                  : Config.primaryColor.withOpacity(0.2),
            ),
            const SizedBox(height: 8),

            // 👩‍⚕️ Patient Info
            _infoRow(
              icon: Icons.person,
              label: t.patient,
              value: billing.patient?.fullName ?? '-',
              context: context,
            ),
            const SizedBox(height: 6),

            // 👨‍⚕️ Doctor Info
            _infoRow(
              icon: Icons.medical_information_outlined,
              label: t.doctor,
              value:
                  '${billing.doctor?.firstName ?? ''} ${billing.doctor?.lastName ?? ''}',
              context: context,
            ),
            const SizedBox(height: 6),

            // 💰 Amount & Status
            Row(
              children: [
                const Icon(
                  FontAwesomeIcons.poundSign,
                  size: 20,
                  color: Config.accentColor,
                ),
                const SizedBox(width: 6),
                Text(
                  '${billing.paidAmount} / ${billing.totalAmount} ${t.localeName == 'en' ? 'SYP' : "ل.س"}',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Config.primaryColor,
                  ),
                ),
                const Spacer(),
                _buildStatusChip(context, billing.status),
              ],
            ),
            const SizedBox(height: 8),

            // 🗓️ Dates
            _infoRow(
              icon: Icons.calendar_today,
              label: t.issued,
              value: _formatDate(billing.dateIssued),
              context: context,
              small: true,
            ),
            if (billing.paymentDate != null)
              _infoRow(
                icon: Icons.payments_rounded,
                label: t.paidOn,
                value: _formatDateTime(billing.paymentDate!),
                context: context,
                small: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
    bool small = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: small ? 16 : 20,
          color: Config.primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium!.copyWith(
              fontSize: small ? 13 : 14,
              color: isDark ? Colors.white60 : Colors.black87,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'paid':
        bgColor = Colors.green.withOpacity(0.15);
        textColor = Colors.green;
        break;
      case 'pending':
        bgColor = Colors.orange.withOpacity(0.15);
        textColor = Colors.orange;
        break;
      default:
        bgColor = Colors.red.withOpacity(0.15);
        textColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3), width: 0.8),
      ),
      child: Text(
        status == 'Paid' ? AppLocalizations.of(context)!.paid : status,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";

  String _formatDateTime(DateTime date) =>
      "${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
}
