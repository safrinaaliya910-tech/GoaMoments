class MembershipModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // 'active', 'inactive'
  final String name;
  final String? description;
  final String? price;

  MembershipModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.name,
    this.description,
    this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
      'name': name,
      'description': description,
      'price': price,
    };
  }

  factory MembershipModel.fromJson(Map<String, dynamic> map) {
    return MembershipModel(
      id: map['id'] ?? '',
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : DateTime.now(),
      status: map['status'] ?? 'active',
      name: map['name'] ?? '',
      description: map['description'],
      price: map['price'],
    );
  }
}
