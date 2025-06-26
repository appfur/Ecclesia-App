class BookModel {
  final String id;
  final String title;
  final String coverImage;
  final String backgroundImage;
  final String description;
  final String author;
  final String category;
  final double price;
  final double? rating;
  final int? ratingCount;

  BookModel({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.backgroundImage,
    required this.description,
    required this.author,
    required this.category,
    required this.price,
    this.rating,
    this.ratingCount,
  });

  factory BookModel.fromFirestore(Map<String, dynamic> data) {
    return BookModel(
      id: data['book_id'] ?? '',
      title: data['title'] ?? '',
      coverImage: data['cover_image'] ?? '',
      backgroundImage: data['background_image'] ?? '',
      description: data['description'] ?? '',
      author: data['author'] ?? '',
      category: '',
      price:
          (data['price'] is int)
              ? (data['price'] as int).toDouble()
              : (data['price'] ?? 0.0),
      rating: null,
      ratingCount: null,
    );
  }

  BookModel copyWithCategory(String categoryId) {
    return BookModel(
      id: id,
      title: title,
      coverImage: coverImage,
      backgroundImage: backgroundImage,
      description: description,
      author: author,
      category: categoryId,
      price: price,
      rating: rating,
      ratingCount: ratingCount,
    );
  }

  BookModel withRating(double rating, int count) {
    return BookModel(
      id: id,
      title: title,
      coverImage: coverImage,
      backgroundImage: backgroundImage,
      description: description,
      author: author,
      category: category,
      price: price,
      rating: rating,
      ratingCount: count,
    );
  }
}
