class PartnerModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // 'active', 'inactive'
  final String name;
  final String category; // 'Hotel', 'Restaurant', 'Spa', 'Yacht'
  final String location;
  final String discountOffer;

  PartnerModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.name,
    required this.category,
    required this.location,
    required this.discountOffer,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
      'name': name,
      'category': category,
      'location': location,
      'discount_offer': discountOffer,
    };
  }

  factory PartnerModel.fromJson(Map<String, dynamic> map) {
    return PartnerModel(
      id: map['id'] ?? '',
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : DateTime.now(),
      status: map['status'] ?? 'active',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      location: map['location'] ?? '',
      discountOffer: map['discount_offer'] ?? '',
    );
  }
}
