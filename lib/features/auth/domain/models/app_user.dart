class AppUser {
  const AppUser({
    required this.id,
    required this.isAnonymous,
    this.email,
    this.displayName,
  });

  final String id;
  final String? email;
  final String? displayName;
  final bool isAnonymous;

  String get resolvedName {
    if ((displayName ?? '').trim().isNotEmpty) {
      return displayName!.trim();
    }
    if ((email ?? '').trim().isNotEmpty) {
      return email!.trim();
    }
    return isAnonymous ? 'Guest User' : 'Movie User';
  }

  String get resolvedEmail {
    if ((email ?? '').trim().isNotEmpty) {
      return email!.trim();
    }
    return isAnonymous ? 'guest@atmmovie.app' : 'No email available';
  }
}
