class AuthSession {
  const AuthSession({
    this.accessToken,
    this.currentUserId,
    this.bootstrapped = false,
  });

  final String? accessToken;
  final int? currentUserId;

  final bool bootstrapped;

  bool get isAuthenticated => accessToken != null && accessToken!.isNotEmpty;
}
