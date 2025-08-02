import 'package:flutter/material.dart';

import '../viewmodel.dart';

void showRatingDialog(BuildContext context, ReaderViewModel vm) {
  int selectedRating = 0;

  showDialog(
    context: context,
    builder:
        (_) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Rate this book"),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return IconButton(
                    icon: Icon(
                      selectedRating >= starIndex
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedRating = starIndex;
                      });
                    },
                  );
                }),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (selectedRating > 0) {
                      vm.rate(selectedRating);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        ),
  );
}
