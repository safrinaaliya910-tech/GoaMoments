class SupportTicketModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // 'open', 'in_progress', 'resolved'
  final String memberId;
  final String subject;
  final String message;
  final String contactMethod; // 'WhatsApp', 'Email', 'Call'

  SupportTicketModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.memberId,
    required this.subject,
    required this.message,
    required this.contactMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
      'member_id': memberId,
      'subject': subject,
      'message': message,
      'contact_method': contactMethod,
    };
  }

  factory SupportTicketModel.fromJson(Map<String, dynamic> map) {
    return SupportTicketModel(
      id: map['id'] ?? '',
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at']) 
          : DateTime.now(),
      status: map['status'] ?? 'open',
      memberId: map['member_id'] ?? '',
      subject: map['subject'] ?? '',
      message: map['message'] ?? '',
      contactMethod: map['contact_method'] ?? 'WhatsApp',
    );
  }
}
