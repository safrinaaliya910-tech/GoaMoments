class ActivationModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // 'active', 'inactive'
  final String memberId;
  final String deviceId;
  final String deviceModel;
  final String activationLocation;
  final DateTime activationTimestamp;

  ActivationModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.memberId,
    required this.deviceId,
    required this.deviceModel,
    required this.activationLocation,
    required this.activationTimestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
      'member_id': memberId,
      'device_id': deviceId,
      'device_model': deviceModel,
      'activation_location': activationLocation,
      'activation_timestamp': activationTimestamp.toIso8601String(),
    };
  }

  factory ActivationModel.fromJson(Map<String, dynamic> map) {
    return ActivationModel(
      id: map['id'] ?? '',
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : DateTime.now(),
      status: map['status'] ?? 'active',
      memberId: map['member_id'] ?? '',
      deviceId: map['device_id'] ?? '',
      deviceModel: map['device_model'] ?? '',
      activationLocation: map['activation_location'] ?? '',
      activationTimestamp: map['activation_timestamp'] != null 
          ? DateTime.parse(map['activation_timestamp']) 
          : DateTime.now(),
    );
  }
}
