import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'models/chapter.dart';
import 'models/page.dart';
import 'models/comment.dart';

class ReaderViewModel extends ChangeNotifier {
  final String bookId;
  bool _isInitialized = false;

  // ——— Book document reference ———
  late final DocumentReference<Map<String, dynamic>> _bookRef;

  // ——— Basic book info ———
  String title = '';
  String coverImage = '';

  // ——— Content ———
  List<ChapterModel> chapters = [];
  List<CommentModel> comments = [];

  // ——— Aggregate stats ———
  int likeCount = 0;
  int loveCount = 0;
  double avgRating = 0.0;
  int ratingCount = 0;

  // ——— Current user's interaction state ———
  bool liked = false;
  bool loved = false;
  int? userRating;

  ReaderViewModel(this.bookId);

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // 1️⃣ Locate the book document in Firestore
    final booksSnap =
        await FirebaseFirestore.instance
            .collectionGroup('books')
            .where('book_id', isEqualTo: bookId)
            .limit(1)
            .get();
    if (booksSnap.docs.isEmpty) return;

    _bookRef = booksSnap.docs.first.reference;
    final data = booksSnap.docs.first.data();
    title = data['title'] ?? '';
    coverImage = data['cover_image'] ?? '';

    // 2️⃣ Load everything else
    await Future.wait([
      _loadChaptersAndPages(),
      _fetchMetadataAndUserInteraction(),
      _loadComments(),
    ]);
  }

  // ─────────────────────────────────────────────────────────────────
  //                 Chapters & Pages
  // ─────────────────────────────────────────────────────────────────
  Future<void> _loadChaptersAndPages() async {
    final chapSnap =
        await _bookRef.collection('chapters').orderBy('order').get();

    chapters = await Future.wait(
      chapSnap.docs.map((doc) async {
        final d = doc.data();
        final pagesSnap =
            await doc.reference
                .collection('pages')
                .orderBy('page_number')
                .get();

        final pages =
            pagesSnap.docs.map((pDoc) {
              final p = pDoc.data();
              return PageModel(
                id: pDoc.id,
                pageNumber: p['page_number'],
                content: p['content'],
              );
            }).toList();

        return ChapterModel(
          id: doc.id,
          title: d['title'],
          imageUrl: d['image_url'] ?? coverImage,
          order: d['order'],
          pages: pages,
        );
      }),
    );

    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────
  //               Metadata & User Interaction
  // ─────────────────────────────────────────────────────────────────
  Future<void> _fetchMetadataAndUserInteraction() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    // 1) Aggregate stats
    final statsDoc = await _bookRef.collection('metadata').doc('stats').get();
    final stats = statsDoc.data() ?? {};
    likeCount = stats['likes'] ?? 0;
    loveCount = stats['love'] ?? 0;
    avgRating = (stats['rating'] ?? 0).toDouble();
    ratingCount = stats['rating_count'] ?? 0;

    // 2) This user’s interaction (if signed in)
    if (uid != null) {
      final interDoc =
          await _bookRef
              .collection('metadata')
              .doc('interactions')
              .collection('users')
              .doc(uid)
              .get();
      if (interDoc.exists) {
        final d = interDoc.data()!;
        liked = d['liked'] ?? false;
        loved = d['loved'] ?? false;
        userRating = d['rating'];
      }
    }

    notifyListeners();
  }

  Future<void> toggleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    liked = !liked;
    likeCount += liked ? 1 : -1;

    final batch = FirebaseFirestore.instance.batch();
    batch.update(_bookRef.collection('metadata').doc('stats'), {
      'likes': likeCount,
    });
    batch.set(
      _bookRef
          .collection('metadata')
          .doc('interactions')
          .collection('users')
          .doc(user.uid),
      {'liked': liked},
      SetOptions(merge: true),
    );
    await batch.commit();
    notifyListeners();
  }

  Future<void> toggleLove() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    loved = !loved;
    loveCount += loved ? 1 : -1;

    final batch = FirebaseFirestore.instance.batch();
    batch.update(_bookRef.collection('metadata').doc('stats'), {
      'love': loveCount,
    });
    batch.set(
      _bookRef
          .collection('metadata')
          .doc('interactions')
          .collection('users')
          .doc(user.uid),
      {'loved': loved},
      SetOptions(merge: true),
    );
    await batch.commit();
    notifyListeners();
  }

  Future<void> rate(int stars) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Recalculate average
    final oldScore = userRating ?? 0;
    final totalScore = avgRating * ratingCount;
    final newTotal = totalScore - oldScore + stars;
    final isNew = userRating == null;
    if (isNew) ratingCount++;
    avgRating = newTotal / ratingCount;
    userRating = stars;

    final batch = FirebaseFirestore.instance.batch();
    batch.update(_bookRef.collection('metadata').doc('stats'), {
      'rating': avgRating,
      'rating_count': ratingCount,
    });
    batch.set(
      _bookRef
          .collection('metadata')
          .doc('interactions')
          .collection('users')
          .doc(user.uid),
      {'rating': stars},
      SetOptions(merge: true),
    );
    await batch.commit();
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────
  //                         Comments
  // ─────────────────────────────────────────────────────────────────
  Future<void> _loadComments() async {
    final snap =
        await FirebaseFirestore.instance
            .collection('comments')
            .doc(bookId)
            .collection('comments')
            .orderBy('timestamp', descending: true)
            .get();

    comments = await Future.wait(
      snap.docs.map((doc) async {
        final d = doc.data();
        // load replies subcollection
        final repliesSnap =
            await doc.reference
                .collection('replies')
                .orderBy('timestamp')
                .get();
        final replies =
            repliesSnap.docs.map((r) {
              final rd = r.data();
              return ReplyModel(
                userId: rd['user_id'],
                userName: rd['user_name'],
                text: rd['content'],
                timestamp: (rd['timestamp'] as Timestamp).toDate(),
              );
            }).toList();

        return CommentModel(
          id: doc.id,
          userId: d['user_id'],
          userName: d['user_name'],
          text: d['content'],
          timestamp: (d['timestamp'] as Timestamp).toDate(),
          replies: replies,
        );
      }),
    );

    notifyListeners();
  }

  Future<void> addComment(String text) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || text.trim().isEmpty) return;

    final ref = FirebaseFirestore.instance
        .collection('comments')
        .doc(bookId)
        .collection('comments');

    final docRef = await ref.add({
      'user_id': user.uid,
      'user_name': user.displayName ?? 'Anonymous',
      'content': text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Insert locally so UI updates immediately
    comments.insert(
      0,
      CommentModel(
        id: docRef.id,
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous',
        text: text.trim(),
        timestamp: DateTime.now(),
        replies: [],
      ),
    );
    notifyListeners();
  }

  Future<void> addReply({
    required String commentId,
    required String text,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || text.trim().isEmpty) return;

    final replyRef = FirebaseFirestore.instance
        .collection('comments')
        .doc(bookId)
        .collection('comments')
        .doc(commentId)
        .collection('replies');

    await replyRef.add({
      'user_id': user.uid,
      'user_name': user.displayName ?? 'Anonymous',
      'content': text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
    // reload comments to pick up new reply
    await _loadComments();
  }
}
