import 'page.dart';

class ChapterModel {
  final String id;
  final String title;
  final String imageUrl;
  final int order;
  final List<PageModel> pages;

  ChapterModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.order,
    required this.pages,
  });
}
