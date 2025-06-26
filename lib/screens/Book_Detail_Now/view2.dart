import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/book_model.dart';
import '../../widgets/paymentSheet.dart';
import 'viewmodel.dart';

class BookDetailScreen extends StatelessWidget {
  final BookModel book;

  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookDetailViewModel(book: book),
      child: Consumer<BookDetailViewModel>(
        builder: (context, vm, _) {
          try {
            if (vm.isLoading || vm.author == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final author = vm.author!; // Safe since we checked above

            return Scaffold(
              backgroundColor: Colors.white,
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Image.network(
                            book.backgroundImage,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          Positioned(
                            top: 80,
                            left: MediaQuery.of(context).size.width / 2 - 50,
                            child: Hero(
                              tag: book.id,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  book.coverImage,
                                  width: 100,
                                  height: 140,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book.title,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),

                      /// ✅ SAFELY showing author
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(author.image),
                            radius: 12,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            author.name,
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: SvgPicture.asset(
                                  'assets/svg/read.svg',
                                  color: Colors.white,
                                ),

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  showProductDetailsBottomSheet(
                                    context,
                                    book,
                                  ); // pass the BookModel here
                                },

                                label: Text(
                                  'Read',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Add to library',
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () {
                                final shareLink =
                                    'https://mayorkayedu.com/book/${book.id}';
                                Share.share(
                                  '📖 Check out this book: $shareLink',
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'About book',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            book.description,
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Similar Books',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 130,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: vm.similarBooks.length,
                          itemBuilder: (_, index) {
                            final similar = vm.similarBooks[index];
                            return GestureDetector(
                              // onTap: () => context.push('/book/${book.id}', extra: book),
                              onTap: () {
                                //    print('📚 Book tapped: ${similar.title}');
                                context.push(
                                  '/book/${similar.id}',
                                  extra: similar,
                                );
                              },
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      similar.coverImage,
                                      width: 80,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      similar.title,
                                      style: GoogleFonts.poppins(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder:
                              (_, __) => const SizedBox(width: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } catch (e, stackTrace) {
            log(
              '💥 Error building BookDetailScreen: $e',
              stackTrace: stackTrace,
            );
            return const Scaffold(
              body: Center(
                child: Text(
                  '⚠️ An unexpected error occurred.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
