import 'package:flutter/material.dart';
import '../models/benefit_model.dart';
import '../models/membership_model.dart';
import '../models/partner_model.dart';
import '../models/support_model.dart';
import '../repositories/content_repository.dart';

class ContentViewModel extends ChangeNotifier {
  final ContentRepository _contentRepository;

  bool _isLoading = false;
  List<MembershipModel> _plans = [];
  List<BenefitModel> _benefits = [];
  List<PartnerModel> _partners = [];

  bool get isLoading => _isLoading;
  List<MembershipModel> get plans => _plans;
  List<BenefitModel> get benefits => _benefits;
  List<PartnerModel> get partners => _partners;

  ContentViewModel(this._contentRepository);

  /// Load membership plans from repository
  Future<void> loadMembershipPlans(bool isDemoMode) async {
    _isLoading = true;
    notifyListeners();

    _plans = await _contentRepository.getMembershipPlans(isDemoMode: isDemoMode);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadBenefits(bool isDemoMode) async {
  _isLoading = true;
  notifyListeners();
  try {
    final data = await _contentRepository.getBenefits(isDemoMode: isDemoMode);
    
    // --- ADD THIS LINE TO DEBUG ---
    debugPrint("DEBUG: Benefits received from Supabase: ${data.length} items");
    for (var b in data) {
      debugPrint("DEBUG: Benefit Title: ${b.title}, Category: ${b.category}");
    }
    
    _benefits = data;
  } catch (e) {
    debugPrint("Error loading benefits: $e");
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  /// Submit a support ticket to the VIP Concierge Desk
  Future<bool> submitConciergeTicket({
    required String memberId,
    required String subject,
    required String message,
    required String contactMethod,
    bool isDemoMode = true,
  }) async {
    _isLoading = true;
    notifyListeners();

    final ticket = SupportTicketModel(
      id: '', // database auto-generates
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: 'open',
      memberId: memberId,
      subject: subject,
      message: message,
      contactMethod: contactMethod,
    );

    final success = await _contentRepository.createSupportTicket(ticket, isDemoMode: isDemoMode);
    
    _isLoading = false;
    notifyListeners();
    return success;
  }
}
