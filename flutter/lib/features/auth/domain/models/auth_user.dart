class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.storeIds,
  });

  final String id;
  final String email;
  final String name;
  final String role;
  final List<String> storeIds;

  String? get primaryStoreId => storeIds.isEmpty ? null : storeIds.first;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final rawStoreIds = json['storeIds'];
    final storeIds = rawStoreIds is List
        ? rawStoreIds.map((value) => value.toString()).toList()
        : <String>[];

    return AuthUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      storeIds: storeIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'storeIds': storeIds,
    };
  }
}
