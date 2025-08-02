import 'package:flutter/material.dart';

import '../models/chapter.dart';
//import '../models/chapter_model.dart';

class ChapterWidget extends StatelessWidget {
  final ChapterModel chapter;

  const ChapterWidget({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Image.network(
              chapter.imageUrl,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
            Container(
              width: double.infinity,
              height: 60,
              color: Colors.black.withOpacity(0.4),
              padding: const EdgeInsets.all(10),
              child: Text(
                chapter.title,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        ...chapter.pages.map(
          (page) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              page.content,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}
