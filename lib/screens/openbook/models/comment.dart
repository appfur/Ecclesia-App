class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime timestamp;
  final List<ReplyModel> replies;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
    required this.replies,
  });
}

class ReplyModel {
  final String userId;
  final String userName;
  final String text;
  final DateTime timestamp;

  ReplyModel({
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
  });
}
