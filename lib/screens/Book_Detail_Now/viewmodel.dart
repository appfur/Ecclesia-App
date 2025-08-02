import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/author_model.dart';
import '../../models/book_model.dart';

class BookDetailViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final BookModel book;

  AuthorModel? author;
  List<BookModel> similarBooks = [];
  bool isLoading = true;
  bool isInLibrary = false;

  bool _disposed = false;
  final String userId;
  BookDetailViewModel({required this.userId, required this.book}) {
    _init();
  }

  Future<void> _init() async {
    try {
      await Future.wait([
        fetchAuthor(),
        checkIfInLibrary(),
        fetchSimilarBooks(),
      ]);
    } catch (e) {
      debugPrint("⚠️ Error loading book detail: $e");
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> fetchAuthor() async {
    final doc = await _firestore.collection('authors').doc(book.author).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        author = AuthorModel.fromFirestore(data);
      }
    }
  }

  Future<void> checkIfInLibrary() async {
    final doc =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('library')
            .doc(book.id)
            .get();

    isInLibrary = doc.exists;
    notifyListeners();
  }

  Future<void> addToLibrary() async {
    final userLibRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('library')
        .doc(book.id);

    await userLibRef.set({
      ...book.toMap(),
      'added_at': FieldValue.serverTimestamp(),
    });

    debugPrint("✅ Book added to library!");
  }

  Future<void> toggleLibraryStatus() async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('library')
        .doc(book.id);

    if (isInLibrary) {
      await ref.delete();
    } else {
      await ref.set({
        ...book.toMap(),
        'added_at': FieldValue.serverTimestamp(),
      });
    }

    isInLibrary = !isInLibrary;
    notifyListeners();
  }

  Future<bool> canAccessBook(BookModel book) async {
    final uid = userId;

    if (book.price == 0) {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('library')
          .doc(book.id)
          .set({...book.toMap(), 'added_at': FieldValue.serverTimestamp()});
      return true;
    }

    final purchasedDoc =
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('purchases')
            .doc(book.id)
            .get();

    return purchasedDoc.exists;
  }

  Future<void> fetchSimilarBooks() async {
    if (book.category.isEmpty) {
      debugPrint("⚠️ Book category is empty.");
      return;
    }

    final snapshot =
        await _firestore
            .collection('library')
            .doc('categories')
            .collection('categories')
            .doc(book.category)
            .collection('books')
            .get();

    similarBooks =
        snapshot.docs
            .map(
              (doc) => BookModel.fromFirestore(
                doc.data(),
              ).copyWithCategory(book.category),
            )
            .where((b) => b.id != book.id)
            .toList();
  }

  static Future<BookModel> fetchBookById(String id) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collectionGroup('books')
            .where('book_id', isEqualTo: id)
            .limit(1)
            .get();

    if (snapshot.docs.isEmpty) throw Exception('Book not found');

    final doc = snapshot.docs.first;

    // Get the parent category document ID from the path
    final categoryPath = doc.reference.parent.parent!.id;

    return BookModel.fromFirestore(doc.data()).copyWithCategory(categoryPath);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
