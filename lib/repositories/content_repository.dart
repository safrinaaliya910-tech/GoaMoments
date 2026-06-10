import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/benefit_model.dart';
import '../models/membership_model.dart';
import '../models/partner_model.dart';
import '../models/support_model.dart';
import '../services/supabase_service.dart';

abstract class ContentRepository {
  Future<List<MembershipModel>> getMembershipPlans({bool isDemoMode = false});
  Future<List<BenefitModel>> getBenefits({bool isDemoMode = false});
  Future<List<PartnerModel>> getServicePartners({bool isDemoMode = false});
  Future<bool> createSupportTicket(SupportTicketModel ticket, {bool isDemoMode = false});
  Future<bool> createBenefit(BenefitModel benefit, {bool isDemoMode = false});
  Future<bool> updateBenefit(BenefitModel benefit, {bool isDemoMode = false});
  Future<bool> deleteBenefit(String id, {bool isDemoMode = false});
}

class ContentRepositoryImpl implements ContentRepository {
  final SupabaseClient? _supabaseClient;
  
  ContentRepositoryImpl(this._supabaseClient);

  SupabaseClient? get _client => _supabaseClient ?? (SupabaseService().isDemoMode ? null : Supabase.instance.client);

  final List<BenefitModel> _mockBenefits = [
    BenefitModel(id: 'm1', title: '5-Star: Taj Exotica', description: 'Ultimate luxury with butler service.', category: 'HOTELS', subcategory: '5-STAR HOTELS', imageUrl: 'https://images.unsplash.com/photo-1571896349842-33c89424de2d', priority: 1, status: 'active', createdAt: DateTime.now(), updatedAt: DateTime.now()),
    BenefitModel(id: 'm2', title: 'Private Villa: The Leela', description: 'Exclusive suites with plunge pools.', category: 'RESORTS', subcategory: 'PRIVATE VILLA RESORTS', imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef', priority: 1, status: 'active', createdAt: DateTime.now(), updatedAt: DateTime.now()),
  ];

  @override
  Future<List<MembershipModel>> getMembershipPlans({bool isDemoMode = false}) async => [];

  @override
  Future<List<BenefitModel>> getBenefits({bool isDemoMode = false}) async {
    // 1. IGNORE isDemoMode. Always try to fetch LIVE data first.
    try {
      if (_client != null) {
        final response = await _client!.from('benefits').select('*');
        
        if (response != null && response is List && response.isNotEmpty) {
          debugPrint("--- LUXURY DATA UNLOCKED: ${response.length} items loaded from Supabase ---");
          return response.map((b) => BenefitModel.fromJson(b as Map<String, dynamic>)).toList();
        }
      }
      debugPrint("DEBUG: Supabase returned empty. Falling back to Mock Data.");
      return _mockBenefits;
    } catch (e) {
      debugPrint('DEBUG: Supabase connection failed: $e. Falling back to Mock.');
      return _mockBenefits;
    }
  }
  @override
  Future<List<PartnerModel>> getServicePartners({bool isDemoMode = false}) async => [];

  @override
  Future<bool> createSupportTicket(SupportTicketModel ticket, {bool isDemoMode = false}) async => true;

  @override
  Future<bool> createBenefit(BenefitModel benefit, {bool isDemoMode = false}) async => true;

  @override
  Future<bool> updateBenefit(BenefitModel benefit, {bool isDemoMode = false}) async => true;

  @override
  Future<bool> deleteBenefit(String id, {bool isDemoMode = false}) async => true;
}