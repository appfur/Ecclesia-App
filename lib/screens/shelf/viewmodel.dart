import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/book_model.dart';

class LibraryViewModel extends ChangeNotifier {
  final FirebaseFirestore firestore;
  //final SharedPreferences prefs;
  final String userId;
  late SharedPreferences prefs;
  // List<BookModel> get books => _books;

  List<BookModel> recentBooks = [];
  Map<String, List<BookModel>> groupedBooks = {}; // Grouped by Today, Yesterday

  LibraryViewModel({required this.firestore, required this.userId});

  Future<void> loadLibrary() async {
    prefs = await SharedPreferences.getInstance();

    await _loadRecentBooks();
    await _loadUserBooks();
  }

  Future<void> _loadRecentBooks() async {
    print("📥 Loading recent books...");
final recentIds = prefs.getStringList('recent_books_$userId') ?? [];
print("🧾 Found recent book IDs: $recentIds");

  //  final recentIds = prefs.getStringList('recent_books_$userId') ?? [];
    final books = <BookModel>[];

    for (final id in recentIds) {
      final doc =
          await firestore
              .collection('users')
              .doc(userId)
              .collection('library')
              .doc(id)
              .get();
      if (doc.exists) {
        books.add(BookModel.fromFirestore(doc.data()!)..copyWithCategory(doc.id));
      }
    }
    recentBooks = books;
    notifyListeners();
  }

  String getRelativeDateGroup(DateTime addedAt) {
    final now = DateTime.now();
    final diff = now.difference(addedAt);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays <= 7) return 'This Week';
    if (diff.inDays <= 15) return 'Last 15 Days';
    if (now.month == addedAt.month && now.year == addedAt.year)
      return 'This Month';
    if (now.year == addedAt.year) return 'Earlier This Year';
    return 'Last Year';
  }

  Future<void> _loadUserBooks() async {
    final snapshot =
        await firestore
            .collection('users')
            .doc(userId)
            .collection('library')
            .get();

    final grouped = <String, List<BookModel>>{};

    for (final doc in snapshot.docs) {
      final book = BookModel.fromFirestore(doc.data())..copyWithCategory(doc.id);
      //  final book = BookModel.fromFirestore(doc.data());
      final addedAt = (doc.data()['added_at'] as Timestamp?)?.toDate();

      if (addedAt != null) {
        final label = getRelativeDateGroup(addedAt);
        grouped.putIfAbsent(label, () => []).add(book);
      }
    }

    groupedBooks = grouped;
    notifyListeners();
  }

  Future<void> _loadUserBook() async {
    final snapshot =
        await firestore
            .collection('users')
            .doc(userId)
            .collection('library')
            .get();
    final now = DateTime.now();

    final today = <BookModel>[];
    final yesterday = <BookModel>[];

    for (final doc in snapshot.docs) {
      final book = BookModel.fromFirestore(doc.data());
      final addedAt = (doc.data()['added_at'] as Timestamp?)?.toDate();
      if (addedAt != null) {
        final diff = now.difference(addedAt).inDays;
        if (diff == 0) {
          today.add(book);
        } else if (diff == 1) {
          yesterday.add(book);
        }
      }
    }

    groupedBooks = {
      if (today.isNotEmpty) 'Today': today,
      if (yesterday.isNotEmpty) 'Yesterday': yesterday,
    };
    notifyListeners();
  }
Future<bool> canAccessBook(BookModel book) async {
  if (book.price == 0) {
  // Add to library silently
  await addBookToLibrary(book);
  return true;
}

  //if (book.price == 0) return true;
  return await isBookPurchased(book.id);
}
final Set<String> _purchasedBooks = {};

Future<void> loadPurchases() async {
  final snapshot = await firestore
    .collection('users')
    .doc(userId)
    .collection('purchases')
    .get();

  _purchasedBooks
    ..clear()
    ..addAll(snapshot.docs.map((doc) => doc.id));

  notifyListeners();
}

bool isBookPurchasedSync(String bookId) => _purchasedBooks.contains(bookId);

  Future<void> addBookToLibrary(BookModel book) async {
    final docRef = firestore
        .collection('users')
        .doc(userId)
        .collection('library')
        .doc(book.id);
    await docRef.set({
      ...book.toMap(),
      'added_at': FieldValue.serverTimestamp(),
    });
    await loadLibrary();
  }

  Future<void> openBook(BookModel book) async {
    final recent = prefs.getStringList('recent_books_$userId') ?? [];
    recent.remove(book.id);
    recent.insert(0, book.id);
    await prefs.setStringList('recent_books_$userId', recent.take(5).toList());
    notifyListeners();
  }

  Future<bool> isBookPurchased(String bookId) async {
    final doc =
        await firestore
            .collection('users')
            .doc(userId)
            .collection('purchases')
            .doc(bookId)
            .get();
    return doc.exists;
  }

  bool isBookPaid(BookModel book) {
    return book.price > 0;
  }

  double getProgress(String bookId) {
    // Use cached data or return mock value here (0.0 - 1.0)
    return 0.3; // Replace with actual logic
  }
}
