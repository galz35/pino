enum AuthorizationStatus { pending, approved, rejected }

enum AuthorizationType { priceOverride, creditLimit, other }

class AuthorizationRequest {
  final String id;
  final String storeId;
  final String requesterId;
  final AuthorizationType type;
  final Map<String, dynamic> details;
  final AuthorizationStatus status;
  final DateTime? createdAt;

  AuthorizationRequest({
    required this.id,
    required this.storeId,
    required this.requesterId,
    required this.type,
    required this.details,
    required this.status,
    this.createdAt,
  });

  factory AuthorizationRequest.fromMap(Map<String, dynamic> data, String id) {
    return AuthorizationRequest(
      id: id,
      storeId: data['storeId'] ?? '',
      requesterId: data['requesterId'] ?? '',
      type: AuthorizationType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => AuthorizationType.other,
      ),
      details: Map<String, dynamic>.from(data['details'] ?? {}),
      status: AuthorizationStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => AuthorizationStatus.pending,
      ),
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : null,
    );
  }

  factory AuthorizationRequest.fromJson(Map<String, dynamic> json) {
    return AuthorizationRequest.fromMap(json, json['id'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'requesterId': requesterId,
      'type': type.name,
      'details': details,
      'status': status.name,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
