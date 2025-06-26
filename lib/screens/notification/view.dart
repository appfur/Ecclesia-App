import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'viewmodel.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loaded = false;
  // bool isLoading = false;

  /*@override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_loaded) {
      final vm = Provider.of<NotificationsViewModel>(context, listen: false);
    // isLoading = true;
//notifyListeners();
      vm.loadNotifications();
    //  isLoading = false;
      _loaded = true;
    }
  }*/
  /*@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (!_loaded) {
    final vm = Provider.of<NotificationsViewModel>(context, listen: false);
  //  vm.loadNotifications();
    vm.loadNotifications().then((_) => vm.markAllAsSeen());
    _loaded = true;
  }
}*/
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
                  child: Text('Clear', style: TextStyle(color: Colors.purple)),
                ),
            ],
          ),
          body:
              // if (vm.isLoading) {
              //return const Center(child: CircularProgressIndicator());
              //}
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
                            ...group.map(
                              (notif) => ListTile(
                                leading:
                                    notif.isGeneral
                                        ? Image.asset(
                                          'assets/icons/logo.jpg',
                                          width: 32,
                                          height: 32,
                                        )
                                        : SvgPicture.asset(
                                          'assets/svg/bell.svg',
                                          width: 32,
                                        ),

                                title: Text(
                                  notif.title,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  notif.body,
                                  style: GoogleFonts.poppins(fontSize: 13),
                                ),
                                trailing: Text(
                                  timeago.format(notif.timestamp),
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ),
                          ];
                        }).toList(),
                  ),
        );
      },
    );
  }
}
