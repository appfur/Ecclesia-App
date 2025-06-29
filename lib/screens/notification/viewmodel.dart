import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/notification.dart';

class NotificationsViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // final String uid = FirebaseAuth.instance.currentUser!.uid;
  // final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid;

  List<AppNotification> _notifications = [];
  List<String> _clearedGeneralIds = [];
  List<String> _seenNotificationIds = [];
  bool isLoading = false;

  List<AppNotification> get notifications => _notifications;
  List<String> get seenNotificationIds => _seenNotificationIds;
  bool get hasUnseenNotifications =>
      _notifications.any((n) => !_seenNotificationIds.contains(n.id));

  StreamSubscription? _personalSubscription;
  StreamSubscription? _generalSubscription;
  StreamSubscription? _seenSubscription;

  NotificationsViewModel({required this.uid}) {
    _initListeners();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading = true;
    notifyListeners();

    try {
      print('🔥 [loadNotifications] Starting for UID: $uid');

      final personalSnap =
          await _db
              .collection('notifications')
              .doc('users')
              .collection(uid)
              .get();
      print('✅ Personal: ${personalSnap.docs.length}');

      final generalSnap =
          await _db
              .collection('notifications')
              .doc('general')
              .collection('items')
              .get();
      print('✅ General: ${generalSnap.docs.length}');

      final clearedSnap =
          await _db
              .collection('users')
              .doc(uid)
              .collection('clearedGeneralNotifications')
              .get();
      print('✅ Cleared: ${clearedSnap.docs.length}');

      final seenSnap =
          await _db
              .collection('users')
              .doc(uid)
              .collection('seenNotifications')
              .get();
      print('✅ Seen: ${seenSnap.docs.length}');

      _clearedGeneralIds = clearedSnap.docs.map((doc) => doc.id).toList();
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

      print('✅ All notifications loaded: ${_notifications.length}');
    } catch (e, st) {
      print('❌ Error loading notifications: $e');
      print('🪵 Stacktrace: $st');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadNotification() async {
    isLoading = true;
    notifyListeners();

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

  void _initListeners() async {
    await _loadClearedGeneralIds();

    _personalSubscription = _db
        .collection('notifications')
        .doc('users')
        .collection(uid)
        .snapshots()
        .listen((_) => _refresh());

    _generalSubscription = _db
        .collection('notifications')
        .doc('general')
        .collection('items')
        .snapshots()
        .listen((_) => _refresh());

    _seenSubscription = _db
        .collection('users')
        .doc(uid)
        .collection('seenNotifications')
        .snapshots()
        .listen((_) => _refresh());

    _refresh(); // initial load
  }

  Future<void> _loadClearedGeneralIds() async {
    final clearedSnap =
        await _db
            .collection('users')
            .doc(uid)
            .collection('clearedGeneralNotifications')
            .get();

    _clearedGeneralIds = clearedSnap.docs.map((doc) => doc.id).toList();
  }

  Future<void> _refresh() async {
    isLoading = true;
    notifyListeners();

    final personalSnap =
        await _db
            .collection('notifications')
            .doc('users')
            .collection(uid)
            .get();

    final generalSnap =
        await _db
            .collection('notifications')
            .doc('general')
            .collection('items')
            .get();

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
    await _loadClearedGeneralIds(); // reload the cleared list
    await _refresh(); // reprocess notifications
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
    await _refresh(); // update UI
  }

  Map<String, List<AppNotification>> get groupedNotifications {
    final now = DateTime.now();
    final today = <AppNotification>[];
    final yesterday = <AppNotification>[];
    final lastMonth = <AppNotification>[];
    final others = <AppNotification>[];

    for (final notif in _notifications) {
      final date = notif.timestamp;

      if (isSameDay(date, now)) {
        today.add(notif);
      } else if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
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
Future<void> deleteNotification(String id) async {
  await _db
      .collection('notifications')
      .doc('users')
      .collection(uid)
      .doc(id)
      .delete();

  _notifications.removeWhere((n) => n.id == id);
  notifyListeners();
}

  @override
  void dispose() {
    _personalSubscription?.cancel();
    _generalSubscription?.cancel();
    _seenSubscription?.cancel();
    super.dispose();
  }
}
