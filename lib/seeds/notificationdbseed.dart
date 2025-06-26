import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppNotification {
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isGeneral;

  AppNotification({
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isGeneral,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'timestamp': Timestamp.fromDate(timestamp),
      'isGeneral': isGeneral,
    };
  }
}

Future<void> notificationDBSeed() async {
  // final uid =
  //   "x6RGlngHSuYO5acGMAUhhxRTJyg2"; //
  final uid =
      FirebaseAuth.instance.currentUser!.uid; // 🔁 REPLACE with your UID
  final db = FirebaseFirestore.instance;

  final now = DateTime.now();

  final sampleNotifications = <AppNotification>[
    // General
    AppNotification(
      title: "Welcome to the App!",
      body: "We’re glad to have you here.",
      timestamp: now.subtract(Duration(hours: 1)),
      isGeneral: true,
    ),
    AppNotification(
      title: "System Update",
      body: "Version 1.5 is now available.",
      timestamp: now.subtract(Duration(days: 1)),
      isGeneral: true,
    ),
    AppNotification(
      title: "Monthly Roundup",
      body: "See what’s new this month.",
      timestamp: DateTime(now.year, now.month - 1, 20),
      isGeneral: true,
    ),
    AppNotification(
      title: "Legacy Notice",
      body: "We’re deprecating old features.",
      timestamp: DateTime(now.year - 1, 5, 10),
      isGeneral: true,
    ),

    // Personal
    AppNotification(
      title: "Payment Received",
      body: "You received \$50 to your account.",
      timestamp: now.subtract(Duration(minutes: 30)),
      isGeneral: false,
    ),
    AppNotification(
      title: "Account Verified",
      body: "Your ID has been successfully verified.",
      timestamp: now.subtract(Duration(days: 1, hours: 2)),
      isGeneral: false,
    ),
    AppNotification(
      title: "Upcoming Event",
      body: "You have a session scheduled on Friday.",
      timestamp: DateTime(now.year, now.month - 1, 5),
      isGeneral: false,
    ),
  ];

  for (final notif in sampleNotifications) {
    if (notif.isGeneral) {
      await db
          .collection('notifications')
          .doc('general')
          .collection('items')
          .add(notif.toMap());
    } else {
      await db
          .collection('notifications')
          .doc('users')
          .collection(uid)
          .add(notif.toMap());
    }
  }

  print('✅ Notification DB seeded successfully');
}
