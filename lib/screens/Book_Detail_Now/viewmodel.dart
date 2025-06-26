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

  bool _disposed = false;

  BookDetailViewModel({required this.book}) {
    _init();
  }

  Future<void> _init() async {
    try {
      await Future.wait([fetchAuthor(), fetchSimilarBooks()]);
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
