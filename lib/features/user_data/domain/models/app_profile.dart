class AppProfile {
  const AppProfile({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.isAnonymous,
    this.photoUrl,
  });

  final String userId;
  final String displayName;
  final String email;
  final bool isAnonymous;
  final String? photoUrl;
}
