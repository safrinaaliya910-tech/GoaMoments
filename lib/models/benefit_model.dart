class BenefitModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final String title;
  final String description;
  final String category;
  final String subcategory; // ADDED THIS
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
    required this.subcategory, // ADDED THIS
    this.imageUrl,
    required this.priority,
  });

  // THIS IS THE FUNCTION THE REPOSITORY IS ASKING FOR
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
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.now(),
      status: map['status'] ?? 'active',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      subcategory: map['subcategory'] ?? 'General', // ADDED THIS
      imageUrl: map['image_url'],
      priority: map['priority'] ?? 0,
    );
  }
}