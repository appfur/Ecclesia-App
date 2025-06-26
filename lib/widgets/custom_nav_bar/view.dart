import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../screens/notification/viewmodel.dart';
import 'viewmodel.dart';

class CustomNavBar extends StatelessWidget {
  final List<String> labels = ['Home', 'Search', 'Library', 'Notification'];
  final List<String> routes = ['/home', '/search', '/library', '/notification'];
  final List<String> icons = [
    'assets/svg/home.svg',
    'assets/svg/search.svg',
    'assets/svg/library.svg',
    'assets/svg/notification.svg',
  ];

  CustomNavBar({super.key});

  /* @override
  Widget build(BuildContext context) {
    final navVM = Provider.of<NavViewModel>(context);
  // final notificationsVM = Provider.of<NotificationsViewModel>(context);
  final notificationsVM = Provider.of<NotificationsViewModel>(context);

    return BottomNavigationBar(
      currentIndex: navVM.selectedIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        navVM.updateIndex(index);
        GoRouter.of(context).go(routes[index]);
      },
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
     /* items: List.generate(4, (index) {
        return BottomNavigationBarItem(
          icon: SvgPicture.asset(
            icons[index],
            height: 24,
            colorFilter: ColorFilter.mode(
              index == navVM.selectedIndex ? Colors.black : Colors.black54,
              BlendMode.srcIn,
            ),
          ),
          label: labels[index],
        );
      }),*/
 items: List.generate(4, (index) {
        Widget iconWidget = SvgPicture.asset(
          icons[index],
          height: 24,
          colorFilter: ColorFilter.mode(
            index == navVM.selectedIndex ? Colors.black : Colors.black54,
            BlendMode.srcIn,
          ),
        );

        // If this is the notification icon, wrap with Stack to add red dot if needed
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

        return BottomNavigationBarItem(
          icon: iconWidget,
          label: labels[index],
        );
      }),
    );
  }*/
  @override
  Widget build(BuildContext context) {
    final navVM = Provider.of<NavViewModel>(context);

    return Consumer<NotificationsViewModel>(
      builder: (context, notificationsVM, _) {
        return BottomNavigationBar(
          currentIndex: navVM.selectedIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            navVM.updateIndex(index);
            GoRouter.of(context).go(routes[index]);
          },
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
                index == navVM.selectedIndex ? Colors.black : Colors.black54,
                BlendMode.srcIn,
              ),
            );

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
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              );
            }

            return BottomNavigationBarItem(
              icon: iconWidget,
              label: labels[index],
            );
          }),
        );
      },
    );
  }
}
