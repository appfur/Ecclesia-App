import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Comment Model
class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime createdAt;
  final String? parentId; // For replies
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.createdAt,
    this.parentId,
    this.replies = const [],
  });

  factory CommentModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CommentModel(
      id: id,
      userId: data['user_id'] ?? '',
      userName: data['user_name'] ?? '',
      userAvatar: data['user_avatar'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      parentId: data['parent_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'content': content,
      'created_at': Timestamp.fromDate(createdAt),
      'parent_id': parentId,
    };
  }
}

// Chapter Model
class ChapterModel {
  final String id;
  final String title;
  final int order;
  final String imageUrl;
  final List<PageModel> pages;

  ChapterModel({
    required this.id,
    required this.title,
    required this.order,
    required this.imageUrl,
    required this.pages,
  });

  factory ChapterModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ChapterModel(
      id: id,
      title: data['title'] ?? '',
      order: data['order'] ?? 0,
      imageUrl: data['image_url'] ?? '',
      pages: [],
    );
  }
}

// Page Model
class PageModel {
  final String id;
  final int pageNumber;
  final String content;
  final String? chapterId;
  final String? chapterTitle;

  PageModel({
    required this.id,
    required this.pageNumber,
    required this.content,
    this.chapterId,
    this.chapterTitle,
  });

  factory PageModel.fromFirestore(Map<String, dynamic> data, String id) {
    return PageModel(
      id: id,
      pageNumber: data['page_number'] ?? 0,
      content: data['content'] ?? '',
    );
  }
}

class BookReaderScree extends StatefulWidget {
  final String bookId;
  final String bookTitle;
  final String bookRef; // Document reference path

  const BookReaderScree({
    Key? key,
    required this.bookId,
    required this.bookTitle,
    required this.bookRef,
  }) : super(key: key);

  @override
  State<BookReaderScree> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScree> {
  final PageController _pageController = PageController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _commentController = TextEditingController();

  List<ChapterModel> chapters = [];
  List<PageModel> allPages = [];
  List<Map<String, dynamic>> pageItems =
      []; // This will store pages with chapter info
  int currentPageIndex = 0;
  bool isLoading = true;
  bool showRatingSection = false;
  double userRating = 0.0;
  int totalPages = 0;

  // Book metadata
  int likes = 0;
  int loves = 0;
  double rating = 0.0;
  int ratingCount = 0;
  bool hasLiked = false;
  bool hasLoved = false;

  @override
  void initState() {
    super.initState();
    _loadBookContent();
  }

  Future<void> _loadBookContent() async {
    try {
      // Load chapters
      final chaptersQuery =
          await _firestore
              .doc(widget.bookRef)
              .collection('chapters')
              .orderBy('order')
              .get();

      List<ChapterModel> loadedChapters = [];
      List<Map<String, dynamic>> loadedPageItems = [];

      for (var chapterDoc in chaptersQuery.docs) {
        final chapter = ChapterModel.fromFirestore(
          chapterDoc.data(),
          chapterDoc.id,
        );

        // Load pages for this chapter
        final pagesQuery =
            await chapterDoc.reference
                .collection('pages')
                .orderBy('page_number')
                .get();

        List<PageModel> chapterPages = [];

        // Add chapter header as first item
        loadedPageItems.add({'type': 'chapter_header', 'chapter': chapter});

        for (var pageDoc in pagesQuery.docs) {
          final page = PageModel.fromFirestore(pageDoc.data(), pageDoc.id);
          chapterPages.add(page);

          // Add page to pageItems
          loadedPageItems.add({
            'type': 'page',
            'page': page,
            'chapter': chapter,
          });
        }

        loadedChapters.add(
          ChapterModel(
            id: chapter.id,
            title: chapter.title,
            order: chapter.order,
            imageUrl: chapter.imageUrl,
            pages: chapterPages,
          ),
        );
      }

      // Load metadata
      final metadataDoc =
          await _firestore
              .doc(widget.bookRef)
              .collection('metadata')
              .doc('stats')
              .get();

      if (metadataDoc.exists) {
        final data = metadataDoc.data()!;
        likes = data['likes'] ?? 0;
        loves = data['love'] ?? 0;
        rating = (data['rating'] ?? 0.0).toDouble();
        ratingCount = data['rating_count'] ?? 0;
      }

      setState(() {
        chapters = loadedChapters;
        pageItems = loadedPageItems;
        totalPages = loadedPageItems.length;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading book content: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildChapterHeader(ChapterModel chapter) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(chapter.imageUrl),
          fit: BoxFit.cover,
          onError: (error, stackTrace) {
            print('Error loading chapter image: $error');
          },
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chapter.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chapter ${chapter.order}',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(PageModel page, ChapterModel chapter) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chapter info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              chapter.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade800,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Page number
          Text(
            'Page ${page.pageNumber}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),

          // Page content
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                page.content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'How did you like this book?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Current rating display
          if (rating > 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Current Rating: ${rating.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Based on $ratingCount ratings',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // Rating Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    userRating = index + 1.0;
                  });
                },
                child: Icon(
                  index < userRating ? Icons.star : Icons.star_border,
                  size: 40,
                  color: Colors.amber,
                ),
              );
            }),
          ),

          const SizedBox(height: 30),

          // Like and Love buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: hasLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                label: 'Like ($likes)',
                onTap: _toggleLike,
                isActive: hasLiked,
              ),
              _buildActionButton(
                icon: hasLoved ? Icons.favorite : Icons.favorite_border,
                label: 'Love ($loves)',
                onTap: _toggleLove,
                isActive: hasLoved,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Submit Rating Button
          if (userRating > 0)
            ElevatedButton(
              onPressed: _submitRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: const Text('Submit Rating'),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: isActive ? Colors.blue : Colors.grey.shade200,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comments',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Add Comment Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Write a comment...',
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _addComment,
                    child: const Text('Post Comment'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Comments List
          StreamBuilder<QuerySnapshot>(
            stream:
                _firestore
                    .doc(widget.bookRef)
                    .collection('comments')
                    .where('parent_id', isNull: true)
                    .orderBy('created_at', descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final comments =
                  snapshot.data!.docs.map((doc) {
                    return CommentModel.fromFirestore(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    );
                  }).toList();

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return _buildCommentCard(comments[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(CommentModel comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(comment.userAvatar),
                onBackgroundImageError: (error, stackTrace) {
                  print('Error loading avatar: $error');
                },
                child:
                    comment.userAvatar.isEmpty
                        ? const Icon(Icons.person)
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _formatDate(comment.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Text(comment.content, style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: TextButton(
              onPressed: () => _showReplyDialog(comment.id),
              child: const Text('Reply'),
            ),
          ),

          // Show replies
          StreamBuilder<QuerySnapshot>(
            stream:
                _firestore
                    .doc(widget.bookRef)
                    .collection('comments')
                    .where('parent_id', isEqualTo: comment.id)
                    .orderBy('created_at')
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SizedBox();
              }

              final replies =
                  snapshot.data!.docs.map((doc) {
                    return CommentModel.fromFirestore(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    );
                  }).toList();

              return Padding(
                padding: const EdgeInsets.only(left: 52),
                child: Column(
                  children:
                      replies.map((reply) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundImage: NetworkImage(
                                      reply.userAvatar,
                                    ),
                                    onBackgroundImageError: (
                                      error,
                                      stackTrace,
                                    ) {
                                      print(
                                        'Error loading reply avatar: $error',
                                      );
                                    },
                                    child:
                                        reply.userAvatar.isEmpty
                                            ? const Icon(Icons.person, size: 16)
                                            : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    reply.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                reply.content,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike() async {
    try {
      setState(() {
        hasLiked = !hasLiked;
        likes += hasLiked ? 1 : -1;
      });

      await _firestore
          .doc(widget.bookRef)
          .collection('metadata')
          .doc('stats')
          .update({'likes': likes});
    } catch (e) {
      print('Error toggling like: $e');
      // Revert state on error
      setState(() {
        hasLiked = !hasLiked;
        likes += hasLiked ? 1 : -1;
      });
    }
  }

  Future<void> _toggleLove() async {
    try {
      setState(() {
        hasLoved = !hasLoved;
        loves += hasLoved ? 1 : -1;
      });

      await _firestore
          .doc(widget.bookRef)
          .collection('metadata')
          .doc('stats')
          .update({'love': loves});
    } catch (e) {
      print('Error toggling love: $e');
      // Revert state on error
      setState(() {
        hasLoved = !hasLoved;
        loves += hasLoved ? 1 : -1;
      });
    }
  }

  Future<void> _submitRating() async {
    try {
      final newRatingCount = ratingCount + 1;
      final newRating = ((rating * ratingCount) + userRating) / newRatingCount;

      await _firestore
          .doc(widget.bookRef)
          .collection('metadata')
          .doc('stats')
          .update({'rating': newRating, 'rating_count': newRatingCount});

      setState(() {
        rating = newRating;
        ratingCount = newRatingCount;
        userRating = 0.0; // Reset user rating after submission
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted successfully!')),
      );
    } catch (e) {
      print('Error submitting rating: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to submit rating')));
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final comment = CommentModel(
        id: '',
        userId: 'current_user_id', // Replace with actual user ID
        userName: 'Current User', // Replace with actual user name
        userAvatar:
            'https://via.placeholder.com/40', // Replace with actual avatar
        content: _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _firestore
          .doc(widget.bookRef)
          .collection('comments')
          .add(comment.toMap());

      _commentController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment added successfully!')),
      );
    } catch (e) {
      print('Error adding comment: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to add comment')));
    }
  }

  void _showReplyDialog(String parentId) {
    final TextEditingController replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reply to Comment'),
          content: TextField(
            controller: replyController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Write your reply...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (replyController.text.trim().isNotEmpty) {
                  try {
                    final reply = CommentModel(
                      id: '',
                      userId: 'current_user_id', // Replace with actual user ID
                      userName: 'Current User', // Replace with actual user name
                      userAvatar:
                          'https://via.placeholder.com/40', // Replace with actual avatar
                      content: replyController.text.trim(),
                      createdAt: DateTime.now(),
                      parentId: parentId,
                    );

                    await _firestore
                        .doc(widget.bookRef)
                        .collection('comments')
                        .add(reply.toMap());

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reply added successfully!'),
                      ),
                    );
                  } catch (e) {
                    print('Error adding reply: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add reply')),
                    );
                  }
                }
              },
              child: const Text('Reply'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (currentPageIndex < totalPages)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${currentPageIndex + 1} / ${totalPages + 2}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            currentPageIndex = index;
            if (index >= totalPages) {
              showRatingSection = true;
            }
          });
        },
        itemCount: totalPages + 2, // +2 for rating and comments sections
        itemBuilder: (context, index) {
          if (index < totalPages) {
            // Display page item (either chapter header or page content)
            final pageItem = pageItems[index];

            if (pageItem['type'] == 'chapter_header') {
              return _buildChapterHeader(pageItem['chapter']);
            } else {
              return _buildPage(pageItem['page'], pageItem['chapter']);
            }
          } else if (index == totalPages) {
            // Rating section
            return SingleChildScrollView(child: _buildRatingSection());
          } else {
            // Comments section
            return SingleChildScrollView(child: _buildCommentsSection());
          }
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed:
                  currentPageIndex > 0
                      ? () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                      : null,
              child: const Text('Previous'),
            ),
            ElevatedButton(
              onPressed:
                  currentPageIndex < totalPages + 1
                      ? () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                      : null,
              child: Text(currentPageIndex >= totalPages ? 'Finish' : 'Next'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _commentController.dispose();
    super.dispose();
  }
}
