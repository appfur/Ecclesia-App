import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../screens/notification/viewmodel.dart';
//import '../../viewmodels/notifications_viewmodel.dart';

class CustomNavBar extends StatelessWidget {
  final StatefulNavigationShell shell;

  CustomNavBar({super.key, required this.shell});

  final List<String> labels = ['Home', 'Search', 'Library', 'Notification'];
  final List<String> icons = [
    'assets/svg/home.svg',
    'assets/svg/search.svg',
    'assets/svg/library.svg',
    'assets/svg/notification.svg',
  ];

  @override
  Widget build(BuildContext context) {
    final notificationsVM = Provider.of<NotificationsViewModel>(context);

    return BottomNavigationBar(
      currentIndex: shell.currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: shell.goBranch,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      items: List.generate(4, (index) {
        Widget iconWidget = SvgPicture.asset(
          icons[index],
          height: 24,
          colorFilter: ColorFilter.mode(
            index == shell.currentIndex ? Colors.black : Colors.black54,
            BlendMode.srcIn,
          ),
        );

        // Red notification dot
        if (index == 3 && notificationsVM.hasUnseenNotifications) {
          iconWidget = Stack(
            clipBehavior: Clip.none,
            children: [
              iconWidget,
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          );
        }

        return BottomNavigationBarItem(icon: iconWidget, label: labels[index]);
      }),
    );
  }
}
