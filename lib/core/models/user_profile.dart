class UserProfileResponse {
  const UserProfileResponse({required this.success, required this.user});

  final bool success;
  final ProfileUser user;

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final user = data is Map<String, dynamic> ? data['user'] : null;
    if (user is! Map<String, dynamic>) {
      throw const FormatException('The profile response does not contain a user.');
    }

    return UserProfileResponse(
      success: json['success'] == true,
      user: ProfileUser.fromJson(user),
    );
  }
}

class ProfileUser {
  const ProfileUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.roles,
    required this.accountStatus,
    required this.lastLogin,
    required this.department,
    required this.additionalDepartments,
  });

  final String? id;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? email;
  final List<ProfileRole> roles;
  final String? accountStatus;
  final DateTime? lastLogin;
  final ProfileDepartment? department;
  final String? additionalDepartments;

  String? get displayName {
    final full = fullName?.trim();
    if (full?.isNotEmpty == true) return full;
    final name = [firstName, lastName]
        .where((part) => part?.trim().isNotEmpty == true)
        .join(' ')
        .trim();
    return name.isEmpty ? null : name;
  }

  List<String> get roleNames => roles
      .map((role) => role.name?.trim())
      .whereType<String>()
      .where((name) => name.isNotEmpty)
      .toList();

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'];
    final rawDepartment = json['department'];
    final rawLastLogin = json['last_login'];
    return ProfileUser(
      id: _stringValue(json['id']),
      firstName: _stringValue(json['first_name']),
      lastName: _stringValue(json['last_name']),
      fullName: _stringValue(json['full_name']),
      email: _stringValue(json['email']),
      roles: rawRoles is List
          ? rawRoles
                .whereType<Map<String, dynamic>>()
                .map(ProfileRole.fromJson)
                .toList()
          : const [],
      accountStatus: _stringValue(json['account_status']),
      lastLogin: rawLastLogin is String ? DateTime.tryParse(rawLastLogin) : null,
      department: rawDepartment is Map<String, dynamic>
          ? ProfileDepartment.fromJson(rawDepartment)
          : null,
      additionalDepartments: _stringValue(json['additional_departments']),
    );
  }
}

class ProfileRole {
  const ProfileRole({required this.name, required this.relations});

  final String? name;
  final List<String> relations;

  factory ProfileRole.fromJson(Map<String, dynamic> json) {
    final rawRelations = json['relations'];
    return ProfileRole(
      name: _stringValue(
        json['name'] ??
            json['display_name'] ??
            json['role_name'] ??
            json['title'],
      ),
      relations: rawRelations is List
          ? rawRelations.map((relation) => relation.toString()).toList()
          : const [],
    );
  }
}

class ProfileDepartment {
  const ProfileDepartment({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.headOfDepartment,
    required this.colleagues,
  });

  final String? id;
  final String? name;
  final String? code;
  final String? description;
  final ProfilePerson? headOfDepartment;
  final List<ProfilePerson> colleagues;

  factory ProfileDepartment.fromJson(Map<String, dynamic> json) {
    final rawHead = json['head_of_department'];
    final rawColleagues = json['colleagues'];
    return ProfileDepartment(
      id: _stringValue(json['id']),
      name: _stringValue(json['name']),
      code: _stringValue(json['code']),
      description: _stringValue(json['description']),
      headOfDepartment: rawHead is Map<String, dynamic>
          ? ProfilePerson.fromJson(rawHead)
          : null,
      colleagues: rawColleagues is List
          ? rawColleagues
                .whereType<Map<String, dynamic>>()
                .map(ProfilePerson.fromJson)
                .toList()
          : const [],
    );
  }
}

class ProfilePerson {
  const ProfilePerson({
    required this.id,
    required this.fullName,
    required this.email,
    required this.roles,
  });

  final String? id;
  final String? fullName;
  final String? email;
  final List<ProfileRole> roles;

  factory ProfilePerson.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'];
    return ProfilePerson(
      id: _stringValue(json['id']),
      fullName: _stringValue(json['full_name']),
      email: _stringValue(json['email']),
      roles: rawRoles is List
          ? rawRoles
                .whereType<Map<String, dynamic>>()
                .map(ProfileRole.fromJson)
                .toList()
          : const [],
    );
  }
}

String? _stringValue(dynamic value) {
  if (value == null) return null;
  final string = value.toString().trim();
  return string.isEmpty ? null : string;
}
