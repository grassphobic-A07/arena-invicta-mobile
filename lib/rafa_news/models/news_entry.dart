// ... imports dan fungsi parsing JSON tetap sama ...

class NewsEntry {
    String id;
    String title;
    String content;
    String author;
    DateTime createdAt;
    String category;
    String sports;
    String? thumbnail;
    int newsViews;
    bool isFeatured;

    NewsEntry({
        required this.id,
        required this.title,
        required this.content,
        required this.author,
        required this.createdAt,
        required this.category,
        required this.sports,
        required this.thumbnail,
        required this.newsViews,
        required this.isFeatured,
    });

    // --- TAMBAHAN LOGIC DI SINI ---

    // 1. Getter untuk Preview Konten (agar tidak error di UI)
    String get contentPreview {
      if (content.length > 80) {
        return "${content.substring(0, 80)}...";
      }
      return content;
    }

    // 2. Getter untuk Time Ago (Opsional, biar cantik "2h ago")
    String get timeAgo {
      final diff = DateTime.now().difference(createdAt);
      if (diff.inDays > 0) return "${diff.inDays}d ago";
      if (diff.inHours > 0) return "${diff.inHours}h ago";
      if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
      return "Just now";
    }

    // 3. Getter untuk Live Badge
    bool get isLive => category.toLowerCase() == 'match';

    // --- AKHIR TAMBAHAN ---

    factory NewsEntry.fromJson(Map<String, dynamic> json) => NewsEntry(
        id: json["id"],
        title: json["title"],
        content: json["content"],
        author: json["author"],
        createdAt: DateTime.parse(json["created_at"]),
        category: json["category"],
        sports: json["sports"],
        thumbnail: json["thumbnail"] ?? "", // Tambahkan null safety
        newsViews: json["news_views"] ?? 0,
        isFeatured: json["is_featured"] ?? false,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "content": content,
        "author": author,
        "created_at": createdAt.toIso8601String(),
        "category": category,
        "sports": sports,
        "thumbnail": thumbnail,
        "news_views": newsViews,
        "is_featured": isFeatured,
    };
}