import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> injectCategoryIdsToBooks() async {
  final firestore = FirebaseFirestore.instance;

  final categoryCollection = firestore
      .collection('library')
      .doc('categories')
      .collection('categories');

  final categorySnapshots = await categoryCollection.get();

  for (final categoryDoc in categorySnapshots.docs) {
    final categoryId = categoryDoc.id;

    final booksCollection = categoryDoc.reference.collection('books');
    final bookSnapshots = await booksCollection.get();

    for (final bookDoc in bookSnapshots.docs) {
      final data = bookDoc.data();

      // If book already has category_id, skip to avoid overwriting
      if (data.containsKey('category_id')) continue;

      await bookDoc.reference.update({'category_id': categoryId});

      print('✅ Updated book ${data['title']} with category_id $categoryId');
    }
  }

  print('🎉 Finished injecting category_id into existing books!');
}
