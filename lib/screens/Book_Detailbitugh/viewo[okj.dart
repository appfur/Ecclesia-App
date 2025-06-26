import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/book_model.dart';

class BookDetailScreen extends StatelessWidget {
  final BookModel book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book.title), automaticallyImplyLeading: true),
      body: Column(
        children: [
          Hero(
            tag: book.id,
            child: Image.network(book.coverImage, height: 300),
          ),
          SizedBox(height: 20),
          Text(book.title, style: GoogleFonts.poppins(fontSize: 22)),
          // Add more book details here if needed
        ],
      ),
    );
  }
}
