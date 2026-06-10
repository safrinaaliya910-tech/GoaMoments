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

  // FIXED: These keys now perfectly match your Supabase Database
  Map<String, dynamic> toJson() {
    return {
      'membership_id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_active': status == 'active', 
      'member_name': name,
      'email': email,
      'phone_number': phone,
      'address': city, 
      'plan_id': planId,
      'activated_at': activationDate?.toIso8601String(), 
    };
  }

  factory MemberModel.fromJson(Map<String, dynamic> map) {
    return MemberModel(
      id: map['membership_id'] ?? '', 
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.now(),
      status: (map['is_active'] == true) ? 'active' : 'pending', 
      name: map['member_name'] ?? '', 
      email: map['email'] ?? '',
      phone: map['phone_number'] ?? '', 
      city: map['address'], 
      planId: null, 
      activationDate: map['activated_at'] != null ? DateTime.parse(map['activated_at']) : null,
    );
  }
}