import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedBooksWithChaptersAndPages() async {
  final firestore = FirebaseFirestore.instance;

  final List<String> images = [
    // ... same images
    "https://th.bing.com/th/id/OIP.2th0-WS12c_oOdtSzrHR3QHaGS?r=0&rs=1&pid=ImgDetMain",
    "https://images-platform.99static.com/RHiIaEEqKAOVs9D5fF70AAgC8tc=/402x190:1446x1234/fit-in/500x500/projects-files/186/18640/1864025/3bb3533b-e169-472f-b854-3a28651993b6.jpg",
    "https://th.bing.com/th/id/OIP.FHtlRAywu7C88tG80EMviAHaFk?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3",
    "https://th.bing.com/th/id/R.921dd34067495abf3e4dc4e22af142a7?rik=o1VqQ6Dgj%2bPzKg&riu=http%3a%2f%2f1.bp.blogspot.com%2f-eCc0nYjfyY4%2fT3U3MoglmGI%2fAAAAAAAAAV4%2fFAQUxoFgJ8s%2fs1600%2fBible.jpg&ehk=V3hrIkoHFP5dMeprkmNjXHiqk5dxky1UEmDYo9pTs%2fg%3d&risl=&pid=ImgRaw&r=0",
  ];

  final categories = [
    {
      "title": "The Kingdom",
      "books": [
        {
          "book_id": "tk_2",
          "title": "Making Peace",
          "cover_image": images[1],
          "background_image": images[2],
          "description":
              "Faith-based tools to create emotional and spiritual peace.",
          "author": "author_2",
        },
        {
          "book_id": "tk_3",
          "title": "Breathe",
          "cover_image": images[3],
          "background_image": images[0],
          "description": "Breathwork meets belief.",
          "author": "author_3",
        },
      ],
    },
  ];

  final categoryCollection = firestore
      .collection('library')
      .doc('categories')
      .collection('categories');

  for (final category in categories) {
    final query =
        await categoryCollection
            .where('title', isEqualTo: category['title'])
            .limit(1)
            .get();

    final categoryDoc =
        query.docs.isNotEmpty
            ? query.docs.first.reference
            : (await categoryCollection.add({'title': category['title']}));

    final categoryId = categoryDoc.id;

    for (final book in category['books'] as List<dynamic>) {
      final bookId = book['book_id'];
      final bookRef = categoryDoc.collection('books').doc(bookId);

      // ✅ Merge to avoid overwriting existing fields like rating, etc.
      await bookRef.set({
        ...book,
        'category_id': categoryId,
        'price': 0.0,
        'added_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final metadataRef = bookRef.collection('metadata').doc('stats');
      final metadataDoc = await metadataRef.get();
      if (!metadataDoc.exists) {
        await metadataRef.set({
          'likes': 0,
          'love': 0,
          'rating': 0.0,
          'rating_count': 0,
        });
      }

      final chaptersSnap = await bookRef.collection('chapters').get();
      if (chaptersSnap.docs.isNotEmpty) {
        print("⚠️ Skipping chapters for ${book['title']} - already exists.");
        continue;
      }

      for (int chapterIndex = 0; chapterIndex < 3; chapterIndex++) {
        final chapterImage =
            (chapterIndex % 2 == 0)
                ? images[chapterIndex % images.length]
                : book['cover_image'];

        final chapterDoc = await bookRef.collection('chapters').add({
          'title': 'Chapter ${chapterIndex + 1}',
          'order': chapterIndex + 1,
          'image_url': chapterImage,
        });

        for (int pageIndex = 0; pageIndex < 5; pageIndex++) {
          await chapterDoc.collection('pages').add({
            'page_number': pageIndex + 1,
            'content':
                'Page ${pageIndex + 1} of Chapter ${chapterIndex + 1} in "${book['title']}".',
          });
        }
      }

      print("✅ Seeded book: ${book['title']} with chapters and pages");
    }
  }

  print("🎉 Done safely seeding books + chapters + pages");
}
