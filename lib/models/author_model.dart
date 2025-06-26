class AuthorModel {
  final String name;
  final String image;
  final List<String> books;

  AuthorModel({required this.name, required this.image, required this.books});

  factory AuthorModel.fromFirestore(Map<String, dynamic> data) {
    return AuthorModel(
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      books: List<String>.from(data['books'] ?? []),
    );
  }
}
