import 'package:cloud_firestore/cloud_firestore.dart';

class BookPageModel {
  final int pageNumber;
  final String content;

  BookPageModel({required this.pageNumber, required this.content});

  factory BookPageModel.fromMap(Map<String, dynamic> m) {
    return BookPageModel(
      pageNumber: m['page_number'] ?? 0,
      content: m['content'] ?? '',
    );
  }
}

class CommentModel {
  final String id;
  final String userId;
  final String text;
  final DateTime timestamp;
  final String? replyTo; // ✅ Added this

  CommentModel({
    required this.id,
    required this.userId,
    required this.text,
    required this.timestamp,
    this.replyTo,
  });

  factory CommentModel.fromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      replyTo: data['replyTo'], // ✅ May be null
    );
  }
}
