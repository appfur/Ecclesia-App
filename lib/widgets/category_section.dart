import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/category_model.dart';

class CategorySection extends StatelessWidget {
  final CategoryModel category;

  const CategorySection({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  context.push(
                    '/category/${category.id}',
                    extra: category.title,
                  );
                },
                child: Text("View all"),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: category.books.length,
            itemBuilder: (_, i) {
              final book = category.books[i];
              return GestureDetector(
                onTap: () {
                  print("🧭 Navigating with book category: ${book.category}");
                  context.push('/book/${book.id}', extra: book);
                },

                child: Container(
                  width: 120,
                  margin: EdgeInsets.only(left: 16),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.network(
                          book.coverImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
