import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/widgets/error-snackbar.dart';
//import '../../models/book_model.dart';
import '../../models/book_model.dart';
import '../../models/category_model.dart';

class HomeViewModel with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  List<CategoryModel> _categories = [];
  bool _isLoading = true;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  /*Future<void> fetchCategorie() async {
    _isLoading = true;
    notifyListeners();

    final snapshot =
        await _firestore
            .collection('library')
            .doc('categories')
            .collection('categories')
            .get();

    if (snapshot.docs.isEmpty) {
      _categories = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _categories = [];

    for (var doc in snapshot.docs) {
      final booksSnapshot = await doc.reference.collection('books').get();
      // Suggested code may be subject to a license. Learn more: ~LicenseLog:40329787.
      final books =
          booksSnapshot.docs
              .map(
                (b) =>
                    BookModel.fromFirestore(b.data()).copyWithCategory(doc.id),
              )
              .toList();

      _categories.add(
        CategoryModel(id: doc.id, title: doc['title'], books: books),
      );
    }

    _isLoading = false;
    notifyListeners();
  }*/

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot =
          await _firestore
              .collection('library')
              .doc('categories')
              .collection('categories')
              .get();

      print("📦 Fetched categories: ${snapshot.docs.length}");

      if (snapshot.docs.isEmpty) {
        _categories = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      _categories = [];

      for (var doc in snapshot.docs) {
        //final booksSnapshot = await doc.reference.collection('books').get();
        final booksSnapshot =
            await doc.reference
                .collection('books')
                .orderBy('title') // Optional: ensure consistent order
                .limit(4)
                .get();

        print("📚 Books in ${doc['title']}: ${booksSnapshot.docs.length}");

        //  final books = booksSnapshot.docs
        // Suggested code may be subject to a license. Learn more: ~LicenseLog:226114195.
        //   .map((b) => BookModel.fromFirestore(b.data()).copyWithCategory(categoryIds: [doc.id]))
        // .toList();
        final books =
            booksSnapshot.docs
                .map(
                  (b) => BookModel.fromFirestore(
                    b.data(),
                  ).copyWithCategory(doc.id),
                )
                .toList();

        _categories.add(
          CategoryModel(id: doc.id, title: doc['title'], books: books),
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      showError('Error fetching books');
      //  print("❌ Error fetching data: $e");
      _isLoading = false;
      notifyListeners();
    }
  }
}
