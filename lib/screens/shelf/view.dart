// 🧠 VIEWMODEL

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
//yimport '../models/book_model.dart';

//import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/book_model.dart';
import '../../widgets/paymentSheet.dart';
import 'viewmodel.dart';
//import '../models/book_model.dart';
//import '../viewmodels/library_viewmodel.dart';

// 📱 SCREEN WIDGET

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LibraryViewModel>();
    final recent = viewModel.recentBooks;
    final grouped = viewModel.groupedBooks;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Library',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body:
          recent.isEmpty && grouped.isEmpty
              ? const EmptyLibrary()
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                /* 
                  if (recent.isNotEmpty)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Just Now",
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 170,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: recent.length,
          itemBuilder: (_, i) => BookThumbnailCard(book: recent[i]),
          separatorBuilder: (_, __) => const SizedBox(width: 12),
        ),
      ),
      const SizedBox(height: 24),
    ],
  )
else
  const SizedBox.shrink(),
  */

                    ...grouped.entries.map(
                      (entry) => BookGroupSection(
                        groupTitle: entry.key,
                        books: entry.value,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

class EmptyLibrary extends StatelessWidget {
  const EmptyLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text("No books yet", style: GoogleFonts.poppins(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            "Your saved books will appear here.",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}

class BookGroupSection extends StatelessWidget {
  final String groupTitle;
  final List<BookModel> books;
  const BookGroupSection({
    super.key,
    required this.groupTitle,
    required this.books,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          groupTitle,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: books.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.65,
          ),
          itemBuilder: (_, i) => BookGridCard(book: books[i]),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class BookThumbnailCard extends StatelessWidget {
  final BookModel book;
  const BookThumbnailCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<LibraryViewModel>();
    final progress = viewModel.getProgress(book.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            book.coverImage,
            width: 100,
            height: 140,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          book.title,
          style: GoogleFonts.poppins(fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 10),
        LinearProgressIndicator(
          value: progress,
          minHeight: 4,
          color: Colors.purple,
        ),
      ],
    );
  }
}


class BookGridCard extends StatelessWidget {
  final BookModel book;
  const BookGridCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<LibraryViewModel>();
    final progress = vm.getProgress(book.id);
    final isPurchased = vm.isBookPurchasedSync(book.id);
    final isPaid = book.price > 0;

    // Badge logic
    Widget? badge;
    if (book.price == 0) {
      badge = _buildBadge(
        color: Colors.green.shade600,
        icon: Icons.check_circle_outline,
        label: 'FREE',
      );
    } else if (isPurchased) {
      badge = _buildBadge(
        color: Colors.purple.shade600,
        icon: Icons.check_circle,
        label: 'Purchased',
      );
    } else {
      badge = _buildBadge(
        color: Colors.black.withOpacity(0.6),
        icon: Icons.lock_outline,
        label: '₦${book.price.toStringAsFixed(0)}',
      );
    }

    return GestureDetector(
     // onTap: () => vm.openBook(book),
      onTap: () async {
  final libraryVM = context.read<LibraryViewModel>();
  final canAccess = await libraryVM.canAccessBook(book);

  if (canAccess) {
    libraryVM.openBook(book);
  } else {
  //  context.push('/payment', extra: book); // adjust route name if needed
  showProductDetailsBottomSheet(
                                    context,
                                    book,
                                  );
  }
},

       onLongPress: () => _showBookOptions(context, book),
       onDoubleTap: () => _showBookOptions(context, book),
                
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  book.coverImage,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: GestureDetector(
                  onTap: () => _showBookOptions(context, book),
                  onLongPress: () => _showBookOptions(context, book),
                  onDoubleTap: () => _showBookOptions(context, book),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (badge != null)
                Positioned(
                  right: 8,
                  top: 8,
                  child: badge,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            book.title,
            style: GoogleFonts.poppins(fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 10,),
          LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }

  //void _showBookOptions(BuildContext context, BookModel book) {
    // Your bottom sheet or option logic here
 // }
}

void _showBookOptions(BuildContext context, BookModel book) {
  final vm = context.read<LibraryViewModel>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(vm.userId)
                .collection('library')
                .doc(book.id)
                .get(),
            builder: (context, snapshot) {
              final addedAt = (snapshot.data?.data() as Map?)?['added_at'];
              final addedDate =
                  (addedAt is Timestamp) ? addedAt.toDate() : null;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(vm.userId)
                    .collection('purchases')
                    .doc(book.id)
                    .get(),
                builder: (context, purchaseSnapshot) {
                  final purchaseData =
                      purchaseSnapshot.data?.data() as Map<String, dynamic>?;

                  final purchaseDate = (purchaseData?['purchased_at']
                          as Timestamp?)
                      ?.toDate();

                  return ListView(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'About Book',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book.title,
                        style: GoogleFonts.poppins(fontSize: 17),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.description,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('About Book'),
                        onTap: () {
                          context.push('/book/${book.id}', extra: book);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete_outline),
                        title: const Text('Remove from Library'),
                        onTap: () async {
                          Navigator.pop(context);
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(vm.userId)
                              .collection('library')
                              .doc(book.id)
                              .delete();
                          vm.loadLibrary();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.monetization_on),
                        title: Text(
                          book.price == 0
                              ? 'FREE'
                              : '₦${book.price.toStringAsFixed(0)}',
                          style:
                              const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      ListTile(
  leading: const Icon(Icons.shopping_bag),
  title: Text(
    purchaseDate != null
        ? 'Purchased ${timeago.format(purchaseDate)}'
        : 'Not purchased yet',
    style: const TextStyle(),
  ),
),

                      if (addedDate != null)
                        ListTile(
                          leading: const Icon(Icons.calendar_today_outlined),
                          title: Text(
                            'Added to library ${timeago.format(addedDate)}',
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}