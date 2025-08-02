import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel.dart';
//import '../viewmodels/reader_viewmodel.dart';
import 'comment_section.dart';
import 'rating_dialog.dart';

class EndOfBookSheet extends StatelessWidget {
  const EndOfBookSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ReaderViewModel>(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.1,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              /*  Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.thumb_up),
                    color: Colors.blue,
                    onPressed: vm.toggleLike,
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite),
                    color: Colors.red,
                    onPressed: vm.toggleLove,
                  ),
                  IconButton(
                    icon: const Icon(Icons.star),
                    color: Colors.orange,
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Rate this book"),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return IconButton(
                              icon: Icon(Icons.star, color: Colors.amber),
                              onPressed: () {
                                vm.rate(index + 1);
                                Navigator.pop(context);
                              },
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),*/
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.thumb_up,
                          color: vm.liked ? Colors.blue : Colors.grey,
                        ),
                        onPressed: vm.toggleLike,
                      ),
                      Text(
                        '${vm.likeCount}',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: vm.loved ? Colors.red : Colors.grey,
                        ),
                        onPressed: vm.toggleLove,
                      ),
                      Text(
                        '${vm.loveCount}',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.star,
                          color:
                              vm.userRating != null
                                  ? Colors.orange
                                  : Colors.grey,
                        ),
                        /*  onPressed: ()  /* show rating dialog as before */
                              => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Rate this book"),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return IconButton(
                              icon: Icon(Icons.star, color: Colors.amber),
                              onPressed: () {
                                vm.rate(index + 1);
                                Navigator.pop(context);
                              },
                            );
                          }),
                        ),
                      ),
                              ),*/
                        onPressed: () => showRatingDialog(context, vm),
                      ),

                      // Text("${vm.rating.toStringAsFixed(1)} (${vm.ratingCount} ratings)"),
                      Text(
                        '${vm.ratingCount} rated',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CommentSection(),
            ],
          ),
        );
      },
    );
  }
}
