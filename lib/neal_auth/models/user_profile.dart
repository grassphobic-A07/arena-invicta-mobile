class UserProfile {
  final String username;
  String displayName;
  String favouriteTeam;
  String avatarUrl;
  String bio;
  final String role;


  UserProfile({
    required this.username,
    required this.displayName,
    required this.favouriteTeam,
    required this.avatarUrl,
    required this.bio,
    required this.role,
  });


  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'] ?? "",
      displayName: json['display_name'] ?? "",
      favouriteTeam: json['favourite_team'] ?? "",
      avatarUrl: json['avatar_url'] ?? "",
      bio: json['bio'] ?? "",
      role: json['role'] ?? "visitor",
    );
  }
}