class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final int? departmentId;
  final String accountStatus;
  final DateTime? lastLogin;
  final DateTime? emailVerifiedAt;
  final DateTime? passwordChangedAt;
  final String? activationToken;
  final DateTime? activatedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.departmentId,
    required this.accountStatus,
    required this.lastLogin,
    required this.emailVerifiedAt,
    required this.passwordChangedAt,
    required this.activationToken,
    required this.activatedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) =>
        value == null ? null : DateTime.parse(value as String);

    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      departmentId: json['department_id'] as int?,
      accountStatus: json['account_status'] as String,
      lastLogin: parseDate(json['last_login']),
      emailVerifiedAt: parseDate(json['email_verified_at']),
      passwordChangedAt: parseDate(json['password_changed_at']),
      activationToken: json['activation_token'] as String?,
      activatedAt: parseDate(json['activated_at']),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }
}
