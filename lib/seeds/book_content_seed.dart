import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedBookContent() async {
  final firestore = FirebaseFirestore.instance;

  final booksQuery =
      await firestore
          .collectionGroup('books') // fetch all books across categories
          .get();

  final List<String> images = [
    "https://th.bing.com/th/id/OIP.2th0-WS12c_oOdtSzrHR3QHaGS?r=0&rs=1&pid=ImgDetMain",
    "https://images-platform.99static.com/RHiIaEEqKAOVs9D5fF70AAgC8tc=/402x190:1446x1234/fit-in/500x500/projects-files/186/18640/1864025/3bb3533b-e169-472f-b854-3a28651993b6.jpg",
    "https://th.bing.com/th/id/OIP.FHtlRAywu7C88tG80EMviAHaFk?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3",
    "https://th.bing.com/th/id/R.921dd34067495abf3e4dc4e22af142a7?rik=o1VqQ6Dgj%2bPzKg&riu=http%3a%2f%2f1.bp.blogspot.com%2f-eCc0nYjfyY4%2fT3U3MoglmGI%2fAAAAAAAAAV4%2fFAQUxoFgJ8s%2fs1600%2fBible.jpg&ehk=V3hrIkoHFP5dMeprkmNjXHiqk5dxky1UEmDYo9pTs%2fg%3d&risl=&pid=ImgRaw&r=0",
  ];

  for (final bookDoc in booksQuery.docs) {
    final bookRef = bookDoc.reference;
    final bookData = bookDoc.data();
    final bookTitle = bookData['title'] ?? 'Untitled';
    final bookCover = bookData['cover_image'];

    print('📘 Seeding content for: $bookTitle');

    // Seed metadata document
    final metadataRef = bookRef.collection('metadata').doc('stats');
    await metadataRef.set({
      'likes': 0,
      'love': 0,
      'rating': 0.0,
      'rating_count': 0,
    });

    // Seed chapters
    for (int chapterIndex = 0; chapterIndex < 3; chapterIndex++) {
      final chapterImage =
          (chapterIndex % 2 == 0)
              ? images[chapterIndex % images.length]
              : bookCover;

      final chapterDoc = await bookRef.collection('chapters').add({
        'title': 'Chapter ${chapterIndex + 1}',
        'order': chapterIndex + 1,
        'image_url': chapterImage,
      });

      // Seed pages inside this chapter
      for (int pageIndex = 0; pageIndex < 5; pageIndex++) {
        await chapterDoc.collection('pages').add({
          'page_number': pageIndex + 1,
          'content':
              'Page ${pageIndex + 1} of Chapter ${chapterIndex + 1} in "$bookTitle".',
        });
      }
    }
  }

  print("✅ Done seeding: Chapters, Pages, Metadata for all books.");
}
