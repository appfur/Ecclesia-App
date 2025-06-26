import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedFirestoreLibrary() async {
  final firestore = FirebaseFirestore.instance;

  // Approved images
  final List<String> images = [
    "https://th.bing.com/th/id/OIP.2th0-WS12c_oOdtSzrHR3QHaGS?r=0&rs=1&pid=ImgDetMain",
    "https://images-platform.99static.com/RHiIaEEqKAOVs9D5fF70AAgC8tc=/402x190:1446x1234/fit-in/500x500/projects-files/186/18640/1864025/3bb3533b-e169-472f-b854-3a28651993b6.jpg",
    "https://th.bing.com/th/id/OIP.FHtlRAywu7C88tG80EMviAHaFk?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3",
    "https://th.bing.com/th/id/R.921dd34067495abf3e4dc4e22af142a7?rik=o1VqQ6Dgj%2bPzKg&riu=http%3a%2f%2f1.bp.blogspot.com%2f-eCc0nYjfyY4%2fT3U3MoglmGI%2fAAAAAAAAAV4%2fFAQUxoFgJ8s%2fs1600%2fBible.jpg&ehk=V3hrIkoHFP5dMeprkmNjXHiqk5dxky1UEmDYo9pTs%2fg%3d&risl=&pid=ImgRaw&r=0",
  ];

  final categories = [
    {
      "title": "Personal Development",
      "books": [
        {
          "book_id": "pd_1",
          "title": "The Lost One",
          "cover_image": images[0],
          "background_image": images[1],
          "description": "Street-smart strategies to succeed without millions.",
          "author": "author_1",
        },
        {
          "book_id": "pd_2",
          "title": "Making Peace",
          "cover_image": images[2],
          "background_image": images[3],
          "description":
              "Learn to make peace with your past and embrace your future.",
          "author": "author_2",
        },
        {
          "book_id": "pd_3",
          "title": "Found Lonely",
          "cover_image": images[1],
          "background_image": images[2],
          "description": "Solitude as a source of power and self-reflection.",
          "author": "author_3",
        },
      ],
    },
    {
      "title": "The Kingdom",
      "books": [
        {
          "book_id": "tk_1",
          "title": "The Lost One",
          "cover_image": images[0],
          "background_image": images[3],
          "description":
              "A spiritual journey of purpose, calling and recovery.",
          "author": "author_1",
        },
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
          "description":
              "Breathwork meets belief: how to align soul and breath.",
          "author": "author_3",
        },
      ],
    },
    {
      "title": "Picks for You",
      "books": [
        {
          "book_id": "pfy_1",
          "title": "Kashna House",
          "cover_image": images[2],
          "background_image": images[1],
          "description":
              "An emotional drama inside Kashna’s legendary mansion.",
          "author": "author_4",
        },
        {
          "book_id": "pfy_2",
          "title": "Lana Night Party",
          "cover_image": images[3],
          "background_image": images[0],
          "description": "A wild party night that reshaped destinies.",
          "author": "author_5",
        },
      ],
    },
  ];

  final categoryCollection = firestore
      .collection('library')
      .doc('categories')
      .collection('categories');

  for (final category in categories) {
    final docRef = await categoryCollection.add({'title': category['title']});

    for (final book in category['books'] as List<dynamic>) {
      await docRef.collection('books').add(book);
    }
  }

  print(
    "✅ Firestore seeding complete with descriptions, backgrounds, and authors!",
  );
}
