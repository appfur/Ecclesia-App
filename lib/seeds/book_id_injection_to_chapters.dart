import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> patchChaptersWithBookId() async {
  final firestore = FirebaseFirestore.instance;

  final booksQuery = await firestore.collectionGroup('books').get();

  for (final bookDoc in booksQuery.docs) {
    final bookRef = bookDoc.reference;
    final bookId = bookDoc.data()['book_id'];

    if (bookId == null || bookId.isEmpty) {
      print("⚠️ Book missing book_id: ${bookRef.path}");
      continue;
    }

    final chapters = await bookRef.collection('chapters').get();
    for (final chap in chapters.docs) {
      final data = chap.data();
      if (!data.containsKey('book_id')) {
        await chap.reference.update({'book_id': bookId});
        print("✅ Patched chapter: ${chap.reference.path}");
      }
    }
  }

  print("🎉 Done patching all chapters with book_id.");
}
