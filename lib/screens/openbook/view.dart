import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import '../viewmodels/reader_viewmodel.dart';
//import '../widgets/chapter_widget.dart';
//import '../widgets/end_of_book_sheet.dart';
import 'viewmodel.dart';
import 'widgets/chapter.dart';
import 'widgets/end_of_book_sheet.dart';

class ReaderScreen extends StatelessWidget {
  const ReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ReaderViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          viewModel.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        //   backgroundColor: Colors.deepPurple,
      ),
      body:
          viewModel.chapters.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.only(bottom: 200),
                    itemCount: viewModel.chapters.length,
                    itemBuilder: (context, index) {
                      return ChapterWidget(chapter: viewModel.chapters[index]);
                    },
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: EndOfBookSheet(), // Interactive section
                  ),
                ],
              ),
    );
  }
}
