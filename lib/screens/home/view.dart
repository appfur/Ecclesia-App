import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/category_section.dart';
import 'viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ecclesia Library',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: GestureDetector(
              onTap: () {
                context.push('/account');
                // Handle tap — maybe show profile screen
                print("👤 Profile tapped");
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage:
                    photoUrl != null && photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                child:
                    (photoUrl == null || photoUrl.isEmpty)
                        ? const Icon(Icons.person, size: 28)
                        : null,
              ),
            ),
          ),
        ],
      ),
      body:
          viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.categories.isEmpty
              ? const Center(
                child: Text(
                  "📚 No Categories Available",
                  style: TextStyle(fontSize: 20),
                ),
              )
              : ListView.builder(
                itemCount: viewModel.categories.length,
                itemBuilder: (_, index) {
                  final category = viewModel.categories[index];
                  return CategorySection(category: category);
                },
              ),
    );
  }
}
