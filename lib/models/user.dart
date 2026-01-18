class User {
  final String id;
  final String name;
  final String email;
  final String chapter;
  final String role;
  final String bio;
  final String profileImageUrl;
  final List<String> interests;
  final DateTime joinDate;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.chapter = '',
    this.role = 'Member',
    this.bio = '',
    this.profileImageUrl = '',
    this.interests = const [],
    DateTime? joinDate,
  }) : joinDate = joinDate ?? DateTime.now();

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? chapter,
    String? role,
    String? bio,
    String? profileImageUrl,
    List<String>? interests,
    DateTime? joinDate,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      chapter: chapter ?? this.chapter,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      interests: interests ?? this.interests,
      joinDate: joinDate ?? this.joinDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'chapter': chapter,
      'role': role,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'interests': interests,
      'joinDate': joinDate.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      chapter: json['chapter'] as String? ?? '',
      role: json['role'] as String? ?? 'Member',
      bio: json['bio'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String? ?? '',
      interests: List<String>.from(json['interests'] as List? ?? []),
      joinDate: DateTime.parse(json['joinDate'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}
