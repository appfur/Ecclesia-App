import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/book_tile.dart';
import 'viewmodel.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Search",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          automaticallyImplyLeading: true,
        ),
        body: Consumer<SearchViewModel>(
          builder:
              (context, vm, _) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // 🔍 Search Bar
                    TextField(
                      onChanged: vm.searchBooks,
                      decoration: InputDecoration(
                        hintText: "Search books",
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // 🏷️ Categories
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children:
                            vm.categories
                                .map(
                                  (cat) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: ChoiceChip(
                                      label: Text(cat),
                                      selected: vm.selectedCategory == cat,
                                      onSelected: (_) => vm.selectCategory(cat),
                                      selectedColor: Colors.black,
                                      labelStyle: GoogleFonts.poppins(
                                        color:
                                            vm.selectedCategory == cat
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                    SizedBox(height: 16),

                    // 📚 Results Grid
                    Expanded(
                      child:
                          vm.isLoading
                              ? Center(child: CircularProgressIndicator())
                              : vm.results.isEmpty
                              ? Center(child: Text("No books found"))
                              : Column(
                                // Suggested code may be subject to a license. Learn more: ~LicenseLog:3889010951.
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Books",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Expanded(
                                    child: GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            mainAxisSpacing: 12,
                                            crossAxisSpacing: 12,
                                            childAspectRatio: 0.6,
                                          ),
                                      itemCount: vm.results.length,
                                      itemBuilder: (_, index) {
                                        final book = vm.results[index];
                                        return BookTile(book: book);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}
