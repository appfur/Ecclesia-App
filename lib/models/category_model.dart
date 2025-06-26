import 'book_model.dart';

class CategoryModel {
  final String id;
  final String title;
  final List<BookModel> books;

  CategoryModel({required this.id, required this.title, required this.books});
}
