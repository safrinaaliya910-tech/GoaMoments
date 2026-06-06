import 'dart:convert';

class MemberModel {
  final String id; // Membership ID
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // 'pending', 'active', 'suspended'
  final String name;
  final String email;
  final String phone;
  final String? city;
  final String? planId;
  final DateTime? activationDate;

  MemberModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.name,
    required this.email,
    required this.phone,
    this.city,
    this.planId,
    this.activationDate,
  });

  MemberModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    String? name,
    String? email,
    String? phone,
    String? city,
    String? planId,
    DateTime? activationDate,
  }) {
    return MemberModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      planId: planId ?? this.planId,
      activationDate: activationDate ?? this.activationDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
      'name': name,
      'email': email,
      'phone': phone,
      'city': city,
      'plan_id': planId,
      'activation_date': activationDate?.toIso8601String(),
    };
  }

  factory MemberModel.fromJson(Map<String, dynamic> map) {
    return MemberModel(
      id: map['membership_id'] ?? '', // Mapping DB 'membership_id' to model 'id'
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.now(),
      status: (map['is_active'] == true) ? 'active' : 'pending', // Logic: boolean is_active to string status
      name: map['member_name'] ?? '', // Mapping DB 'member_name'
      email: map['email'] ?? '',
      phone: map['phone_number'] ?? '', // Mapping DB 'phone_number'
      city: map['address'], // Mapping DB 'address' to 'city' or add address field to model
      planId: null, // Add if needed
      activationDate: map['activated_at'] != null ? DateTime.parse(map['activated_at']) : null,
    );
  }
}
