import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

Future<void> seedBookPrices() async {
  final firestore = FirebaseFirestore.instance;
  final booksQuery = await firestore.collectionGroup('books').get();

  final random = Random();

  for (final bookDoc in booksQuery.docs) {
    final price = 500 + random.nextInt(1500); // price between 500 - 2000

    await bookDoc.reference.update({'price': price});

    print("💰 Set price ₦$price for '${bookDoc.data()['title']}'");
  }

  print("✅ All books updated with prices!");
}
