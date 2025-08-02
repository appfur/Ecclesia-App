import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../viewmodel.dart';
import '../models/comment.dart';

class CommentSection extends StatefulWidget {
  const CommentSection({super.key});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController commentController = TextEditingController();
  final Map<String, TextEditingController> replyControllers = {};
  String? replyingToCommentId;

  @override
  void dispose() {
    commentController.dispose();
    for (final controller in replyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ReaderViewModel>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Comments",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        /// ✏️ Add a new comment
        TextField(
          controller: commentController,
          decoration: InputDecoration(
            hintText: "Write a comment...",
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (commentController.text.trim().isNotEmpty && user != null) {
                  vm.addComment(commentController.text.trim());
                  commentController.clear();
                }
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        /// 📭 No comments
        if (vm.comments.isEmpty)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/svg/no-comment.svg', height: 70),
              const SizedBox(height: 16),
              const Text(
                "No comments yet. Be the first to comment.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          )
        /// 💬 Comment list
        else
          Column(
            children:
                vm.comments.map((CommentModel comment) {
                  final isReplying = replyingToCommentId == comment.id;
                  replyControllers[comment.id] ??= TextEditingController();

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 👤 Username & comment text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              comment.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              timeago.format(comment.timestamp),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(comment.text),

                        /// ↩️ Reply icon
                        TextButton.icon(
                          icon: const Icon(Icons.reply, size: 16),
                          label: const Text(
                            "Reply",
                            style: TextStyle(fontSize: 14),
                          ),
                          onPressed: () {
                            setState(() {
                              replyingToCommentId =
                                  isReplying ? null : comment.id;
                            });
                          },
                        ),

                        /// 📝 Reply input
                        if (isReplying)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              top: 8,
                              bottom: 8,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: replyControllers[comment.id],
                                    decoration: const InputDecoration(
                                      hintText: "Write a reply...",
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: () async {
                                    final text =
                                        replyControllers[comment.id]!.text
                                            .trim();
                                    if (text.isNotEmpty && user != null) {
                                      await vm.addReply(
                                        commentId: comment.id,
                                        text: text,
                                      );
                                      replyControllers[comment.id]!.clear();
                                      setState(() {
                                        replyingToCommentId = null;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                        /// 🗨️ Display replies
                        ...comment.replies.map(
                          (reply) => Padding(
                            padding: const EdgeInsets.only(left: 16.0, top: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.subdirectory_arrow_right,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("${reply.userName}: ${reply.text}"),
                                      Text(
                                        timeago.format(reply.timestamp),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
      ],
    );
  }
}
