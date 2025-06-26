import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book_model.dart';

class BookTile extends StatelessWidget {
  final BookModel book;
  const BookTile({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/book/${book.id}', extra: book),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(book.coverImage, fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 6),
          Text(
            book.title,
            style: GoogleFonts.poppins(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
