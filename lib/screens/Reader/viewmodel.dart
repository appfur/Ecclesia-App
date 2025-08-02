import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/book_model.dart';

import '../../models/book_reader.dart';

class ReaderViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final BookModel book;
  ReaderViewModel(this.book);

  String chapterId = '';
  String chapterTitle = '';
  String? chapterImage;
  List<BookPageModel> pages = [];
  int currentPage = 0;

  int likeCount = 0, loveCount = 0;
  double ratingAvg = 0.0;
  int ratingCount = 0;
  List<CommentModel> comments = [];
  bool isInitialized = false;

  Future<void> init() async {
    if (isInitialized) return;
    try {
      await Future.wait([loadMetadata(), loadChapters(), loadComments()]);
    } catch (e) {
      print("❌ init error: $e");
    }
    isInitialized = true;
    notifyListeners();
  }

  Future<void> loadChapters() async {
    try {
      final bookPath = _db
          .collection('library')
          .doc('categories')
          .collection('categories')
          .doc(book.categoryId)
          .collection('books')
          .doc(book.id);

      print("📘 Looking in path: ${bookPath.path}");

      final chaptersSnap =
          await bookPath.collection('chapters').orderBy('order').get();

      if (chaptersSnap.docs.isEmpty) {
        print("⚠️ No chapters found for book ${book.title} (${book.id})");
        return;
      }

      final firstChapter = chaptersSnap.docs.first;
      chapterId = firstChapter.id;
      chapterTitle = firstChapter['title'];
      chapterImage = firstChapter['image_url'];

      final pagesSnap =
          await firstChapter.reference
              .collection('pages')
              .orderBy('page_number')
              .get();

      pages =
          pagesSnap.docs.map((d) => BookPageModel.fromMap(d.data())).toList();

      print("📖 Loaded ${pages.length} pages from chapter: $chapterTitle");
    } catch (e) {
      print("❌ loadChapters error: $e");
    }
  }

  Future<void> loadChapte() async {
    try {
      final snap =
          await _db
              .collectionGroup('chapters')
              .where('book_id', isEqualTo: book.id)
              .orderBy('order')
              .get();
      if (snap.docs.isEmpty) return;

      final chap = snap.docs.first;
      chapterId = chap.id;
      chapterTitle = chap['title'];
      chapterImage = chap['image_url'];

      final pagesSnap =
          await chap.reference.collection('pages').orderBy('page_number').get();
      pages =
          pagesSnap.docs.map((d) => BookPageModel.fromMap(d.data())).toList();
    } catch (e) {
      print("❌ loadChapters: $e");
    }
  }

  Future<void> loadMetadata() async {
    try {
      final metaRef = _db
          .collection('books')
          .doc(book.categoryId)
          .collection('books')
          .doc(book.id)
          .collection('metadata')
          .doc('stats');
      final doc = await metaRef.get();
      if (doc.exists) {
        final m = doc.data()!;
        likeCount = m['likes'] ?? 0;
        loveCount = m['love'] ?? 0;
        ratingAvg = (m['rating'] as num?)?.toDouble() ?? 0.0;
        ratingCount = m['rating_count'] ?? 0;
      }
    } catch (e) {
      print("❌ loadMetadata: $e");
    }
  }

  Future<void> loadComments() async {
    try {
      final snap =
          await _db
              .collection('comments')
              .where('book_id', isEqualTo: book.id)
              .orderBy('timestamp')
              .get();
      comments = snap.docs.map((d) => CommentModel.fromDoc(d)).toList();
    } catch (e) {
      print("❌ loadComments: $e");
    }
  }

  void nextPage() {
    if (currentPage < pages.length - 1) {
      currentPage++;
      notifyListeners();
    }
  }

  void prevPage() {
    if (currentPage > 0) {
      currentPage--;
      notifyListeners();
    }
  }

  Future<void> addReaction(String type) async {
    try {
      final ref = _db
          .collection('books')
          .doc(book.categoryId)
          .collection('books')
          .doc(book.id)
          .collection('metadata')
          .doc('stats');
      final field = (type == 'like') ? 'likes' : 'love';
      await ref.update({field: FieldValue.increment(1)});
      await loadMetadata();
      notifyListeners();
    } catch (e) {
      print("❌ addReaction: $e");
    }
  }

  Future<void> submitRating(int value) async {
    try {
      final ref = _db
          .collection('books')
          .doc(book.categoryId)
          .collection('books')
          .doc(book.id)
          .collection('metadata')
          .doc('stats');

      final newCount = ratingCount + 1;
      final newAvg = (ratingAvg * ratingCount + value) / newCount;
      await ref.update({'rating': newAvg, 'rating_count': newCount});
      await loadMetadata();
      notifyListeners();
    } catch (e) {
      print("❌ submitRating: $e");
    }
  }

  Future<void> postComment(String text, [String? replyTo]) async {
    try {
      await _db.collection('comments').add({
        'book_id': book.id,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'text': text,
        'timestamp': Timestamp.now(),
        'replyTo': replyTo,
      });
      await loadComments();
      notifyListeners();
    } catch (e) {
      print("❌ postComment: $e");
    }
  }
}
