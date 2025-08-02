import 'package:flutter/material.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String? tag; // optional for Hero animation

  const FullScreenImageViewer({super.key, required this.imageUrl, this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child:
            tag != null
                ? Hero(
                  tag: tag!,
                  child: InteractiveViewer(
                    child: Image.network(imageUrl, fit: BoxFit.contain),
                  ),
                )
                : InteractiveViewer(
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
      ),
    );
  }
}
