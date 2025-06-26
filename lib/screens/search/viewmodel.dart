import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/book_model.dart';

class SearchViewModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  List<String> _categories = [];
  String _selectedCategory = '';
  List<BookModel> _results = [];
  String _query = '';
  bool _loading = false;

  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  List<BookModel> get results => _results;
  bool get isLoading => _loading;

  SearchViewModel() {
    fetchCategories();
  }

  void fetchCategories() async {
    final snapshot =
        await _firestore
            .collection('library')
            .doc('categories')
            .collection('categories')
            .get();

    _categories = snapshot.docs.map((e) => e['title'] as String).toList();
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = _selectedCategory == category ? '' : category;
    searchBooks(_query); // re-search
  }

  void searchBook(String query) async {
    _query = query;
    _results = [];
    _loading = true;
    notifyListeners();

    final categorySnapshot =
        await _firestore
            .collection('library')
            .doc('categories')
            .collection('categories')
            .get();

    for (final doc in categorySnapshot.docs) {
      if (_selectedCategory.isNotEmpty && doc['title'] != _selectedCategory)
        continue;

      final booksSnapshot =
          await doc.reference
              .collection('books')
              .where('title', isGreaterThanOrEqualTo: query)
              .where('title', isLessThanOrEqualTo: '$query\uf8ff')
              .get();
      // ← get category
      final categoryId = doc.id;

      //final doc = snapshot.docs.first;
      //final categoryPath = doc.parent.parent!.id; // ← get category
      _results.addAll(
        booksSnapshot.docs.map(
          (doc) =>
              BookModel.fromFirestore(doc.data()).copyWithCategory(categoryId),
        ),
      );
    }

    _loading = false;
    notifyListeners();
  }

  void searchB(String query) async {
    _query = query.toLowerCase();
    _results = [];
    _loading = true;
    notifyListeners();

    final categorySnapshot =
        await _firestore
            .collection('library')
            .doc('categories')
            .collection('categories')
            .get();

    for (final doc in categorySnapshot.docs) {
      if (_selectedCategory.isNotEmpty && doc['title'] != _selectedCategory)
        continue;

      // Get all books (or limit if too big)
      final booksSnapshot = await doc.reference.collection('books').get();

      final filtered =
          booksSnapshot.docs
              .map((doc) => BookModel.fromFirestore(doc.data()))
              .where(
                (book) => book.title.toLowerCase().contains(_query),
              ) // ✅ case-insensitive match
              .toList();

      _results.addAll(filtered);
    }

    _loading = false;
    notifyListeners();
  }

  void searchBooks(String query) async {
    // _query = query.toLowerCase();
    _query = query.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

    _results = [];
    _loading = true;
    notifyListeners();

    final categorySnapshot =
        await _firestore
            .collection('library')
            .doc('categories')
            .collection('categories')
            .get();

    for (final doc in categorySnapshot.docs) {
      final categoryTitle = doc['title'].toString().toLowerCase();

      // Skip if a specific category is selected and this one doesn't match
      if (_selectedCategory.isNotEmpty &&
          categoryTitle != _selectedCategory.toLowerCase()) {
        continue;
      }

      // Fetch all books in this category
      final booksSnapshot = await doc.reference.collection('books').get();
      final categoryId = doc.id;

      final books =
          booksSnapshot.docs
              .map(
                (doc) => BookModel.fromFirestore(
                  doc.data(),
                ).copyWithCategory(categoryId),
              )
              .toList();

      // Check if category title matches the query
      final categoryMatches = categoryTitle.contains(_query);

      // Filter books by title containing the query
      final filteredBooks =
          books
              .where((book) => book.title.toLowerCase().contains(_query))
              .toList();

      // If category matches, add **all books** in this category
      if (categoryMatches) {
        _results.addAll(books);
      } else {
        // Otherwise, only add filtered books by title
        _results.addAll(filteredBooks);
      }
    }

    _loading = false;
    notifyListeners();
  }
}
