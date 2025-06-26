import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/book_model.dart';

class CategoryDetailViewModel extends ChangeNotifier {
  final String categoryId;
  final _firestore = FirebaseFirestore.instance;

  final List<BookModel> _books = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;

  List<BookModel> get books => _books;
  bool get isLoading => _isLoading;

  CategoryDetailViewModel(this.categoryId) {
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    var query = _firestore
        .collection('library')
        .doc('categories')
        .collection('categories')
        .doc(categoryId)
        .collection('books')
        .orderBy('title')
        .limit(9);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      _lastDoc = snapshot.docs.last;
      //  _books.addAll(snapshot.docs.map((doc) => BookModel.fromFirestore(doc.data())));
      _books.addAll(
        snapshot.docs.map(
          (doc) =>
              BookModel.fromFirestore(doc.data()).copyWithCategory(categoryId),
        ),
      );
    }

    if (snapshot.docs.length < 9) _hasMore = false;

    _isLoading = false;
    notifyListeners();
    print("📚 Loaded ${_books.length} books with category $categoryId");
    print("📘 First book category: ${_books.first.category}");
  }
}
