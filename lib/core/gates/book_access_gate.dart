/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/book_reader.dart';

class ReadAccessGate extends StatelessWidget {
  final String userId;
  final String bookId;

  const ReadAccessGate({required this.userId, required this.bookId, super.key});

  Future<bool> isBookPaid() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('paid_books')
        .doc(bookId)
        .get()
        .then((doc) => doc.exists);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isBookPaid(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final paid = snapshot.data!;
        if (paid) {
          return BookReaderScreen(bookId: bookId);
        } else {
          return PaymentScreen(bookId: bookId);
        }
      },
    );
  }
}*/
//https://chatgpt.com/g/g-6DQc8zeTA-flutter-expert/c/684ffc13-d41c-8001-95a5-051daf7196c5
