import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'viewmodel.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryId;
  final String title;

  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryDetailViewModel(categoryId),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
        body: Consumer<CategoryDetailViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading && vm.books.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            return NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (!vm.isLoading &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  vm.fetchBooks();
                }
                return false;
              },
              child: GridView.builder(
                padding: EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.6,
                ),
                itemCount: vm.books.length + (vm.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= vm.books.length) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final book = vm.books[index];
                  return GestureDetector(
                    onTap: () => context.push('/book/${book.id}', extra: book),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Hero(
                              tag: book.id,
                              child: Image.network(
                                book.coverImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
