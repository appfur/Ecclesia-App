import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../models/book_model.dart';

Future<void> showProductDetailsBottomSheet(
  BuildContext context,
  BookModel book,
) async {
  final firestore = FirebaseFirestore.instance;

  // 1. Find the book document from Firestore
  final bookRefQuery =
      await firestore
          .collection('library')
          .doc('categories')
          .collection('categories')
          .doc(book.category)
          .collection('books')
          .where('book_id', isEqualTo: book.id)
          .get();

  if (bookRefQuery.docs.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Book not found.')));
    return;
  }

  final bookDoc = bookRefQuery.docs.first.reference;

  // 2. Get chapters
  final chapterSnap = await bookDoc.collection('chapters').get();
  final chapterCount = chapterSnap.size;

  // 3. Get metadata (rating)
  final statsDoc = await bookDoc.collection('metadata').doc('stats').get();
  final rating = (statsDoc.data()?['rating'] ?? 0.0).toDouble();
  final ratingCount = (statsDoc.data()?['rating_count'] ?? 0).toInt();

  // 4. Get author name using book.author ID
  String authorName = book.author;
  final authorSnap =
      await firestore.collection('authors').doc(book.author).get();
  if (authorSnap.exists) {
    authorName = authorSnap.data()?['name'] ?? authorName;
  }

  // 5. Get category title using book.category ID
  String categoryTitle = book.category;
  final categorySnap =
      await firestore
          .collection('library')
          .doc('categories')
          .collection('categories')
          .doc(book.category)
          .get();

  if (categorySnap.exists) {
    categoryTitle = categorySnap.data()?['title'] ?? categoryTitle;
  }

  // 6. Show the bottom sheet
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Product details',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Title:', book.title),
            const SizedBox(height: 12),
            _buildDetailRow('Author:', authorName),
            const SizedBox(height: 12),
            _buildDetailRow('Category:', categoryTitle),
            const SizedBox(height: 12),
            _buildDetailRow('Chapters:', chapterCount.toString()),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rating:', style: GoogleFonts.poppins(fontSize: 15)),
                Row(children: _buildStarRating(rating)),
              ],
            ),
            if (ratingCount > 0)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '($ratingCount reviews)',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/pay', extra: book);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Purchase',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                //  Text(
                //'₦ ${book.price.toStringAsFixed(2)}',
                //  style: GoogleFonts.poppins(
                //fontSize: 18,
                //    fontWeight: FontWeight.bold,
                //  ),
                Text(
                  '₦ ${book.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    // Don't use GoogleFonts here
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildDetailRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w400),
      ),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    ],
  );
}

List<Widget> _buildStarRating(double rating) {
  List<Widget> stars = [];
  int fullStars = rating.floor();
  bool hasHalfStar = (rating - fullStars) >= 0.5;

  for (int i = 0; i < fullStars; i++) {
    stars.add(const Icon(Icons.star, size: 18, color: Colors.amber));
  }

  if (hasHalfStar) {
    stars.add(const Icon(Icons.star_half, size: 18, color: Colors.amber));
  }

  while (stars.length < 5) {
    stars.add(const Icon(Icons.star_border, size: 18, color: Colors.grey));
  }

  return stars;
}
