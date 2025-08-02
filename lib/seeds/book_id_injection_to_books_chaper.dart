import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> patchChaptersWithBookId() async {
  final firestore = FirebaseFirestore.instance;

  // Get all book docs
  final booksQuery = await firestore.collectionGroup('books').get();

  for (final bookDoc in booksQuery.docs) {
    final bookRef = bookDoc.reference;
    final bookId = bookDoc.data()['book_id'];

    if (bookId == null || bookId.toString().isEmpty) {
      print("⚠️ Skipped book with missing book_id at ${bookRef.path}");
      continue;
    }

    final chaptersQuery = await bookRef.collection('chapters').get();

    for (final chapterDoc in chaptersQuery.docs) {
      final chapterRef = chapterDoc.reference;
      final data = chapterDoc.data();

      // Skip if already has book_id
      if (data.containsKey('book_id')) continue;

      await chapterRef.update({'book_id': bookId});
      print('✅ Patched chapter at ${chapterRef.path} with book_id: $bookId');
    }
  }

  print('🎉 All existing chapters updated with book_id if missing.');
}
