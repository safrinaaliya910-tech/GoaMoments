class BenefitModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // 'active', 'inactive'
  final String title;
  final String description;
  final String category; // 'Hotels', 'Restaurants', 'Nightlife', etc.
  final String? imageUrl;
  final int priority;

  BenefitModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.title,
    required this.description,
    required this.category,
    this.imageUrl,
    required this.priority,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
      'title': title,
      'description': description,
      'category': category,
      'image_url': imageUrl,
      'priority': priority,
    };
  }

  factory BenefitModel.fromJson(Map<String, dynamic> map) {
    return BenefitModel(
      id: map['id'] ?? '',
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : DateTime.now(),
      status: map['status'] ?? 'active',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['image_url'],
      priority: map['priority'] ?? 0,
    );
  }
}
