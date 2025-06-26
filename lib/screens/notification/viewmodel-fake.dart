import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/notification.dart';

class NotificationsViewModel extends ChangeNotifier {
  //final String uid;
  NotificationsViewModel();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<AppNotification> _notifications = [];
  List<String> _clearedGeneralIds = [];
  // Suggested code may be subject to a license. Learn more: ~LicenseLog:717341281.
  String uid = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = false;
  List<String> _seenNotificationIds = [];
  List<AppNotification> get notifications => _notifications;
  bool get hasUnseenNotifications =>
      _notifications.any((n) => !_seenNotificationIds.contains(n.id));
  List<String> get seenNotificationIds => _seenNotificationIds;

  Future<void> loadNotifications() async {
    isLoading = true;
    notifyListeners();
    final personalSna =
        await _db
            .collection('notifications')
            .doc('users')
            .collection(uid)
            .get();
    final personalSnap =
        await _db
            .collection('notifications')
            .doc('users') // 'users' is a doc
            .collection(uid) // {uid} is a subcollection under that doc
            .get();

    final generalSnap =
        await _db
            .collection('notifications')
            .doc('general')
            .collection('items')
            .get();

    final clearedSnap =
        await _db
            .collection('users')
            .doc(uid)
            .collection('clearedGeneralNotifications')
            .get();

    _clearedGeneralIds = clearedSnap.docs.map((doc) => doc.id).toList();
    final seenSnap =
        await _db
            .collection('users')
            .doc(uid)
            .collection('seenNotifications')
            .get();

    _seenNotificationIds = seenSnap.docs.map((doc) => doc.id).toList();

    final personal = personalSnap.docs.map(
      (doc) => AppNotification(
        id: doc.id,
        title: doc['title'],
        body: doc['body'],
        timestamp: doc['timestamp'].toDate(),
        isGeneral: false,
      ),
    );

    final general = generalSnap.docs
        .where((doc) => !_clearedGeneralIds.contains(doc.id))
        .map(
          (doc) => AppNotification(
            id: doc.id,
            title: doc['title'],
            body: doc['body'],
            timestamp: doc['timestamp'].toDate(),
            isGeneral: true,
          ),
        );

    _notifications = [...personal, ...general]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    // notifyListeners();
    isLoading = false;
    notifyListeners();
  }

  Future<void> clearGeneralNotifications(List<String> ids) async {
    final batch = _db.batch();
    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('clearedGeneralNotifications');
    for (final id in ids) {
      batch.set(ref.doc(id), {'cleared': true});
    }
    await batch.commit();
    await loadNotifications(); // refresh
  }

  Map<String, List<AppNotification>> get groupedNotifications {
    final now = DateTime.now();
    final today = <AppNotification>[];
    final yesterday = <AppNotification>[];
    final lastMonth = <AppNotification>[];
    final others = <AppNotification>[];

    for (final notif in _notifications) {
      final date = notif.timestamp;
      final diff = now.difference(date);

      if (isSameDay(date, now)) {
        today.add(notif);
      } else if (isSameDay(date, now.subtract(Duration(days: 1)))) {
        yesterday.add(notif);
      } else if (date.month == now.month - 1 && date.year == now.year) {
        lastMonth.add(notif);
      } else {
        others.add(notif);
      }
    }

    final Map<String, List<AppNotification>> grouped = {};
    if (today.isNotEmpty) grouped['Today'] = today;
    if (yesterday.isNotEmpty) grouped['Yesterday'] = yesterday;
    if (lastMonth.isNotEmpty) grouped['Last Month'] = lastMonth;
    if (others.isNotEmpty) grouped['Older'] = others;

    return grouped;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> markAllAsSeen() async {
    final seenRef = _db
        .collection('users')
        .doc(uid)
        .collection('seenNotifications');

    final batch = _db.batch();

    for (var notif in _notifications) {
      if (!_seenNotificationIds.contains(notif.id)) {
        final docRef = seenRef.doc(notif.id);
        batch.set(docRef, {'seen': true});
      }
    }

    await batch.commit();
    await loadNotifications(); // refresh seen state
  }
}
