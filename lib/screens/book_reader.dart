import 'package:flutter/material.dart';

class BookReaderScreen extends StatefulWidget {
  final String bookId;

  const BookReaderScreen({required this.bookId, super.key});

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  final PageController _pageController = PageController();
  final List<String> dummyPages = List.generate(
    10,
    (index) => "This is the content of page ${index + 1}.",
  );

  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != currentPage) {
        setState(() => currentPage = newPage);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (currentPage + 1) / dummyPages.length;

    return Scaffold(
      appBar: AppBar(title: Text("Reading: ${widget.bookId}")),
      body: Column(
        children: [
          LinearProgressIndicator(value: progress),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: dummyPages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      dummyPages[index],
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text("Page ${currentPage + 1} of ${dummyPages.length}"),
          ),
        ],
      ),
    );
  }
}
