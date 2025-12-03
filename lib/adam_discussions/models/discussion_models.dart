/// Models for the discussions feature

class DiscussionThread {
  const DiscussionThread({
    required this.id,
    required this.title,
    required this.authorDisplay,
    required this.createdAt,
    required this.commentCount,
    required this.upvoteCount,
    required this.viewsCount,
    this.body,
    this.newsId,
    this.newsTitle,
    this.newsSummary,
  });

  factory DiscussionThread.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>? ?? {};
    final news = json['news'] as Map<String, dynamic>? ?? {};
    return DiscussionThread(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      body: json['body'] as String?,
      authorDisplay: author['display_name'] as String? ??
          author['username'] as String? ??
          'Anonim',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      commentCount: json['comment_count'] as int? ?? 0,
      upvoteCount: json['upvote_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      newsId: news['uuid'] as String?,
      newsTitle: news['title'] as String?,
      newsSummary: news['summary'] as String?,
    );
  }

  final int id;
  final String title;
  final String? body;
  final String authorDisplay;
  final DateTime createdAt;
  final int commentCount;
  final int upvoteCount;
  final int viewsCount;
  final String? newsId;
  final String? newsTitle;
  final String? newsSummary;

  List<String> get tags {
    final list = <String>[];
    if (newsTitle != null) list.add('News');
    if (upvoteCount > 10) list.add('Populer');
    if (commentCount == 0) list.add('Belum Dijawab');
    return list;
  }

  String get relativeTime => formatRelative(createdAt);
}

class DiscussionComment {
  const DiscussionComment({
    required this.id,
    required this.content,
    required this.authorDisplay,
    required this.authorUsername,
    required this.createdAt,
    this.parentId,
  });

  factory DiscussionComment.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>? ?? {};
    return DiscussionComment(
      id: json['id'] as int,
      content: json['content'] as String? ?? '',
      authorDisplay: author['display_name'] as String? ??
          author['username'] as String? ??
          'Anonim',
      authorUsername: author['username'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      parentId: json['parent_id'] as int?,
    );
  }

  final int id;
  final String content;
  final String authorDisplay;
  final String authorUsername;
  final DateTime createdAt;
  final int? parentId;

  String get relativeTime => formatRelative(createdAt);
}

// Utility functions
String formatCount(int value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}m';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
  return value.toString();
}

String formatRelative(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inHours < 1) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  final weeks = (diff.inDays / 7).floor();
  if (weeks < 4) return '${weeks}w';
  final months = (diff.inDays / 30).floor();
  if (months < 12) return '${months}mo';
  final years = (diff.inDays / 365).floor();
  return '${years}y';
}
