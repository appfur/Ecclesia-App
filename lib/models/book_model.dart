import 'package:cloud_firestore/cloud_firestore.dart';

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
  DateTime? addedAt;

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
    this.addedAt,
  });

  factory BookModel.fromFirestore(Map<String, dynamic> data) {
    return BookModel(
      id: data['book_id'] ?? '',
      title: data['title'] ?? '',
      coverImage: data['cover_image'] ?? '',
      backgroundImage: data['background_image'] ?? '',
      description: data['description'] ?? '',
      author: data['author'] ?? '',
      //category: '',
      category: data['category'] ?? '',

      price:
          (data['price'] is int)
              ? (data['price'] as int).toDouble()
              : (data['price'] ?? 0.0),
      rating: null,
      ratingCount: null,
      addedAt: (data['added_at'] as Timestamp?)?.toDate(), // ✅ add this

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
      addedAt: addedAt,
    );
  }
Map<String, dynamic> toMap() {
  return {
    'book_id': id,
    'title': title,
    'cover_image': coverImage,
    'background_image': backgroundImage,
    'description': description,
    'author': author,
    'category': category,
    'price': price,
    'rating': rating,
    'rating_count': ratingCount,
    'added_at': addedAt,
  };
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
