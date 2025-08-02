import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book_model.dart';
import 'viewmodel.dart';

class ReaderScre extends StatelessWidget {
  final BookModel book;
  const ReaderScre({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReaderViewModel(book),
      child: Consumer<ReaderViewModel>(
        builder: (context, vm, _) {
          if (!vm.isInitialized) {
            vm.init(); // Call init once
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (vm.pages.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: Text(book.title)),
              body: const Center(child: Text('No pages available')),
            );
          }

          final page = vm.pages[vm.currentPage];

          return Scaffold(
            appBar: AppBar(
              leading: const BackButton(),
              title: Text(book.title),
            ),
            body: Column(
              children: [
                if (vm.chapterImage != null) Image.network(vm.chapterImage!),
                Text(vm.chapterTitle, style: const TextStyle(fontSize: 18)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      page.content,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite),
                      onPressed: () => vm.addReaction('love'),
                    ),
                    Text('${vm.loveCount}'),
                    IconButton(
                      icon: const Icon(Icons.thumb_up),
                      onPressed: () => vm.addReaction('like'),
                    ),
                    Text('${vm.likeCount}'),
                    IconButton(
                      icon: const Icon(Icons.star),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) {
                            int sel = 0;
                            return StatefulBuilder(
                              builder: (ctx, set) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text("Rate this book"),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        for (int i = 1; i <= 5; i++)
                                          IconButton(
                                            icon: Icon(
                                              i <= sel
                                                  ? Icons.star
                                                  : Icons.star_border,
                                            ),
                                            onPressed: () => set(() => sel = i),
                                          ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        vm.submitRating(sel);
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text("Submit"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    Text(vm.ratingAvg.toStringAsFixed(1)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('Page ${vm.currentPage + 1}/${vm.pages.length}'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: vm.prevPage,
                      child: const Text('Prev'),
                    ),
                    TextButton(
                      onPressed: vm.nextPage,
                      child: const Text('Next'),
                    ),
                  ],
                ),
                const SafeArea(child: SizedBox(height: 50)),
              ],
            ),
            bottomSheet: DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.1,
              maxChildSize: 0.6,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.grey,
                      ),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'Comments',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            ...vm.comments
                                .where((c) => c.replyTo == null)
                                .map(
                                  (cm) => ListTile(
                                    title: Text(cm.text),
                                    subtitle: Text('User: ${cm.userId}'),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.reply),
                                      onPressed: () {
                                        final ctrl = TextEditingController();
                                        showDialog(
                                          context: context,
                                          builder:
                                              (_) => AlertDialog(
                                                title: const Text('Reply'),
                                                content: TextField(
                                                  controller: ctrl,
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      vm.postComment(
                                                        ctrl.text,
                                                        cm.id,
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Send'),
                                                  ),
                                                ],
                                              ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      onSubmitted:
                                          (text) => vm.postComment(text),
                                      decoration: const InputDecoration(
                                        hintText: 'Type comment',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.send),
                                    onPressed: () {
                                      // Optional: handle manual send
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
