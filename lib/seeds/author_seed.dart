import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedAuthors() async {
  final firestore = FirebaseFirestore.instance;

  final authors = [
    {
      "id": "author_1",
      "name": "Adeyemi Kennedy Joy",
      "image":
          "https://images-platform.99static.com/RHiIaEEqKAOVs9D5fF70AAgC8tc=/402x190:1446x1234/fit-in/500x500/projects-files/186/18640/1864025/3bb3533b-e169-472f-b854-3a28651993b6.jpg",
      "books": ["pd_1", "tk_1"],
    },
    {
      "id": "author_2",
      "name": "Jackson One",
      "image":
          "https://th.bing.com/th/id/OIP.2th0-WS12c_oOdtSzrHR3QHaGS?r=0&rs=1&pid=ImgDetMain",
      "books": ["pd_2", "tk_2"],
    },
    {
      "id": "author_3",
      "name": "Mara David",
      "image":
          "https://th.bing.com/th/id/OIP.FHtlRAywu7C88tG80EMviAHaFk?w=221&h=180&c=7&r=0&o=7&pid=1.7&rm=3",
      "books": ["pd_3", "tk_3"],
    },
    {
      "id": "author_4",
      "name": "Tina Kashna",
      "image":
          "https://th.bing.com/th/id/R.921dd34067495abf3e4dc4e22af142a7?rik=o1VqQ6Dgj%2bPzKg&riu=http%3a%2f%2f1.bp.blogspot.com%2f-eCc0nYjfyY4%2fT3U3MoglmGI%2fAAAAAAAAAV4%2fFAQUxoFgJ8s%2fs1600%2fBible.jpg&ehk=V3hrIkoHFP5dMeprkmNjXHiqk5dxky1UEmDYo9pTs%2fg%3d&risl=&pid=ImgRaw&r=0",
      "books": ["pfy_1"],
    },
    {
      "id": "author_5",
      "name": "Lana Devlin",
      "image":
          "https://images-platform.99static.com/RHiIaEEqKAOVs9D5fF70AAgC8tc=/402x190:1446x1234/fit-in/500x500/projects-files/186/18640/1864025/3bb3533b-e169-472f-b854-3a28651993b6.jpg",
      "books": ["pfy_2"],
    },
  ];

  final authorCollection = firestore.collection('authors');

  for (final author in authors) {
    await authorCollection.doc(author['id'] as String?).set({
      "name": author['name'],
      "image": author['image'],
      "books": author['books'],
    });
  }

  print("✅ Author seeding complete!");
}
