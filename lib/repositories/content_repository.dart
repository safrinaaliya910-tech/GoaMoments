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
  
  // Admin Panel Readiness CRUDs
  Future<bool> createBenefit(BenefitModel benefit, {bool isDemoMode = false});
  Future<bool> updateBenefit(BenefitModel benefit, {bool isDemoMode = false});
  Future<bool> deleteBenefit(String id, {bool isDemoMode = false});
}

class ContentRepositoryImpl implements ContentRepository {
  final SupabaseClient? _supabaseClient;
  
  SupabaseClient? get _client => _supabaseClient ?? (SupabaseService().isDemoMode ? null : Supabase.instance.client);

  // Mock content database for Demo Mode
  final List<MembershipModel> _mockPlans = [
    MembershipModel(
      id: 'diamond',
      name: 'Diamond Membership',
      description: 'Ultra-exclusive access to premium Goa experiences, yacht charters, and 24/7 concierge.',
      price: '₹1,50,000/yr',
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MembershipModel(
      id: 'platinum',
      name: 'Platinum Membership',
      description: 'Elite entry to Goa top retreats, VIP club seating, and private dining events.',
      price: '₹90,000/yr',
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    MembershipModel(
      id: 'gold',
      name: 'Gold Membership',
      description: 'Curated experiences, luxury dining discounts, and boutique hotel stays.',
      price: '₹50,000/yr',
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final List<BenefitModel> _mockBenefits = [
    BenefitModel(
      id: 'b1',
      title: 'W Goa - Villa Stay',
      description: 'Complimentary 2-night stay in a private luxury chalet with plunge pool and panoramic beach views.',
      category: 'Hotels',
      imageUrl: 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&q=80&w=800',
      priority: 1,
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    BenefitModel(
      id: 'b2',
      title: 'Gunpowder Restaurant',
      description: 'Priority table reservations and a complimentary premium chef-tasting menu for two.',
      category: 'Restaurants',
      imageUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&q=80&w=800',
      priority: 2,
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    BenefitModel(
      id: 'b3',
      title: 'Club Cubana VIP Lounge',
      description: 'Direct queue bypass and access to the private VIP balcony with complimentary premium bottles.',
      category: 'Nightlife',
      imageUrl: 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&q=80&w=800',
      priority: 3,
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    BenefitModel(
      id: 'b4',
      title: 'Private Yacht Charter',
      description: 'Exclusive 4-hour sunset cruise along the Mandovi river with champagne and gourmet catering.',
      category: 'Experiences',
      imageUrl: 'https://images.unsplash.com/photo-1567899378494-47b22a2ae96a?auto=format&fit=crop&q=80&w=800',
      priority: 4,
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    BenefitModel(
      id: 'b5',
      title: 'Taj Exotica Beach Dinner',
      description: 'Candlelit oceanfront dinner with dedicated butler service and customized seafood platter.',
      category: 'VIP Access',
      imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&q=80&w=800',
      priority: 5,
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  final List<PartnerModel> _mockPartners = [
    PartnerModel(
      id: 'p1',
      name: 'W Goa',
      category: 'Hotel',
      location: 'Vagator',
      discountOffer: '20% off Spa and Food & Beverage',
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    PartnerModel(
      id: 'p2',
      name: 'Thalassa',
      category: 'Restaurant',
      location: 'Siolim',
      discountOffer: 'Complimentary welcome drinks & premium table bookings',
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    PartnerModel(
      id: 'p3',
      name: 'Lilliput',
      category: 'Nightlife',
      location: 'Anjuna',
      discountOffer: 'Free entry & 15% off total bill',
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  ContentRepositoryImpl(this._supabaseClient);

  @override
  Future<List<MembershipModel>> getMembershipPlans({bool isDemoMode = false}) async {
    if (isDemoMode || _client == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockPlans;
    }

    try {
      final response = await _client!
          .from('membership_plans')
          .select()
          .eq('status', 'active');
      return (response as List).map((p) => MembershipModel.fromJson(p)).toList();
    } catch (e) {
      print('Error getting plans: $e');
      return [];
    }
  }

  @override
  Future<List<BenefitModel>> getBenefits({bool isDemoMode = false}) async {
    if (isDemoMode || _client == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockBenefits;
    }

    try {
      final response = await _client!
          .from('benefits')
          .select()
          .eq('status', 'active')
          .order('priority', ascending: true);
      return (response as List).map((b) => BenefitModel.fromJson(b)).toList();
    } catch (e) {
      print('Error getting benefits: $e');
      return [];
    }
  }

  @override
  Future<List<PartnerModel>> getServicePartners({bool isDemoMode = false}) async {
    if (isDemoMode || _client == null) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockPartners;
    }

    try {
      final response = await _client!
          .from('service_partners')
          .select()
          .eq('status', 'active');
      return (response as List).map((p) => PartnerModel.fromJson(p)).toList();
    } catch (e) {
      print('Error getting partners: $e');
      return [];
    }
  }

  @override
  Future<bool> createSupportTicket(SupportTicketModel ticket, {bool isDemoMode = false}) async {
    if (isDemoMode || _client == null) {
      await Future.delayed(const Duration(seconds: 1));
      print('--- MOCK SUPPORT TICKET SUBMITTED ---');
      print('Subject: ${ticket.subject}');
      print('Message: ${ticket.message}');
      print('Contact Method: ${ticket.contactMethod}');
      return true;
    }

    try {
      await _client!.from('support_tickets').insert(ticket.toJson());
      return true;
    } catch (e) {
      print('Error creating support ticket: $e');
      return false;
    }
  }

  @override
  Future<bool> createBenefit(BenefitModel benefit, {bool isDemoMode = false}) async {
    if (isDemoMode || _client == null) {
      _mockBenefits.add(benefit);
      return true;
    }
    try {
      await _client!.from('benefits').insert(benefit.toJson());
      return true;
    } catch (e) {
      print('Error creating benefit: $e');
      return false;
    }
  }

  @override
  Future<bool> updateBenefit(BenefitModel benefit, {bool isDemoMode = false}) async {
    if (isDemoMode || _client == null) {
      final idx = _mockBenefits.indexWhere((b) => b.id == benefit.id);
      if (idx != -1) {
        _mockBenefits[idx] = benefit;
        return true;
      }
      return false;
    }
    try {
      await _client!.from('benefits').update(benefit.toJson()).eq('id', benefit.id);
      return true;
    } catch (e) {
      print('Error updating benefit: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteBenefit(String id, {bool isDemoMode = false}) async {
    if (isDemoMode || _client == null) {
      _mockBenefits.removeWhere((b) => b.id == id);
      return true;
    }
    try {
      await _client!.from('benefits').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting benefit: $e');
      return false;
    }
  }
}
