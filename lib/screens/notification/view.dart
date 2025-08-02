import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../models/notification.dart';
import 'viewmodel.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final vm = Provider.of<NotificationsViewModel>(context, listen: false);
      vm.loadNotifications().then((_) => vm.markAllAsSeen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsViewModel>(
      builder: (context, vm, _) {
        final grouped = vm.groupedNotifications;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Notification',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            actions: [
              if (vm.notifications.any((n) => n.isGeneral))
                TextButton(
                  onPressed: () {
                    final toClear =
                        vm.notifications
                            .where((n) => n.isGeneral)
                            .map((n) => n.id)
                            .toList();
                    vm.clearGeneralNotifications(toClear);
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Colors.purple),
                  ),
                ),
            ],
          ),
          body:
              vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : grouped.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/no_notification.jpg',
                          height: 120,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Notifications Yet',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView(
                    children:
                        grouped.entries.expand((entry) {
                          final label = entry.key;
                          final group = entry.value;

                          return [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(
                                label,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            ...group.map((notif) {
                              final isUserNotification = !notif.isGeneral;

                              return isUserNotification
                                  ? Dismissible(
                                    key: Key(notif.id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      color: Colors.red,
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onDismissed: (_) {
                                      Provider.of<NotificationsViewModel>(
                                        context,
                                        listen: false,
                                      ).deleteNotification(notif.id);
                                    },
                                    child: _buildNotifTile(notif),
                                  )
                                  : _buildNotifTile(notif);
                            }),
                          ];
                        }).toList(),
                  ),
        );
      },
    );
  }

  Widget _buildNotifTile(AppNotification notif) {
    return ListTile(
      leading:
          notif.isGeneral
              ? Image.asset('assets/icons/logo.jpg', width: 32, height: 32)
              : SvgPicture.asset('assets/svg/bell.svg', width: 32),
      title: Text(
        notif.title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(notif.body, style: GoogleFonts.poppins(fontSize: 13)),
      trailing: Text(
        timeago.format(notif.timestamp),
        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[800]),
      ),
    );
  }
}
