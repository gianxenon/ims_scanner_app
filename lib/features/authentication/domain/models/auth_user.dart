class AuthUser {
  const AuthUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.groupId,
    required this.roleId,
    required this.isValid,
    required this.lockout,
    required this.mobileNo,
    required this.avatar,
  });

  final String userId;
  final String name;
  final String email;
  final String groupId;
  final String roleId;
  final String isValid;
  final String lockout;
  final String mobileNo;
  final String avatar;
}
