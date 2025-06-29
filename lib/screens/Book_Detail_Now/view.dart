import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/book_model.dart';
//import '../../viewmodels/book_detail_viewmodel.dart';
import 'viewmodel.dart';

class BookDetailScree extends StatelessWidget {
  final BookModel book;

  const BookDetailScree({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => BookDetailViewModel(
            book: book,
            userId: FirebaseAuth.instance.currentUser!.uid,
          ),
      child: Consumer<BookDetailViewModel>(
        //  print("📚 similarBooks count: ${vm.similarBooks.length}");
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            //body: vm.isLoading
            body:
                (vm.isLoading || vm.author == null)
                    ? const Center(child: CircularProgressIndicator())
                    : SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Top image with back and cover
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
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                  ),
                                ),
                                Positioned(
                                  top: 80,
                                  left:
                                      MediaQuery.of(context).size.width / 2 -
                                      50,
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
                            if (vm.author != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      vm.author!.image,
                                    ),
                                    radius: 12,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    vm.author!.name,
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: SvgPicture.asset(
                                        'assets/svg/read.svg',
                                        color: Colors.white,
                                        //  width: 32,
                                      ),
                                     // onPressed: () {
                                        onPressed: () async {
  final canAccess = await vm.canAccessBook(book);
  if (canAccess) {
   // context.push('/reader/${book.id}', extra: book); // Open book
  } else {
    context.push('/payment', extra: book); // Go to payment
  }
},
//
         //                             },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Add to library',
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.share),
                                    onPressed: () {
                                      final shareLink =
                                          'https://ecclisia.com/book/${book.id}';
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                scrollDirection: Axis.horizontal,
                                itemCount: vm.similarBooks.length,

                                // print("📚 similarBooks count: ${vm.similarBooks.length}");
                                itemBuilder: (_, index) {
                                  final similar = vm.similarBooks[index];
                                  return GestureDetector(
                                    onTap:
                                        () => context.push(
                                          '/book/${book.id}',
                                          extra: book,
                                        ),
                                    // onTap: () {
                                    //   print('📚 Book tapped: ${similar.title}');
                                    //  context.push(
                                    //   '/book/${similar.id}',
                                    //   extra: similar,
                                    //  );
                                    // },
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),

                                        //  print("📚 similarBooks count: ${vm.similarBooks.length}");
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (_, __) => const SizedBox(width: 12),
                              ),
                            ),

                            //  print("📚 similarBooks count: ${vm.similarBooks.length}");
                          ],
                        ),
                      ),
                    ),
          );
        },
      ),
    );
  }
}

//https://chatgpt.com/g/g-6DQc8zeTA-flutter-expert/c/6846f51f-c040-8008-b5a3-e17c289a2890
