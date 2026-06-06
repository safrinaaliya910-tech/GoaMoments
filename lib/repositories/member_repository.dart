import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/member_model.dart';
import '../services/supabase_service.dart';

abstract class MemberRepository {
  Future<MemberModel?> getMemberById(String id, {bool isDemoMode = false});
  Future<MemberModel?> verifyMembership({
    required String membershipId,
    required String email,
    required String phone,
    bool isDemoMode = false,
  });
  Future<bool> updateMemberProfile(MemberModel member, {bool isDemoMode = false});
  Future<List<MemberModel>> getAllMembers({bool isDemoMode = false});
  Future<bool> updateMemberStatus(String memberId, String status, {bool isDemoMode = false});
}

class MemberRepositoryImpl implements MemberRepository {
  final SupabaseClient? _supabaseClient;
  
  SupabaseClient? get _client => _supabaseClient ?? (SupabaseService().isDemoMode ? null : Supabase.instance.client);

  MemberRepositoryImpl(this._supabaseClient);

  @override
  Future<MemberModel?> getMemberById(String id, {bool isDemoMode = false}) async {
    if (isDemoMode || _client == null) {
      // Mock logic can be kept here if needed
      return null;
    }

    try {
      final response = await _client!
          .from('memberships')
          .select()
          .eq('membership_id', id)
          .maybeSingle();

      if (response == null) return null;
      return MemberModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting member by ID: $e');
      return null;
    }
  }

  @override
  Future<MemberModel?> verifyMembership({
    required String membershipId,
    required String email,
    required String phone,
    bool isDemoMode = false,
  }) async {
    if (isDemoMode || _client == null) {
      // Return null or mock logic here
      return null;
    }

    try {
      final response = await _client!
          .from('memberships')
          .select()
          .eq('membership_id', membershipId.trim())
          .eq('email', email.trim())
          .eq('phone_number', phone.trim())
          .maybeSingle();

      if (response == null) return null;
      return MemberModel.fromJson(response);
    } catch (e) {
      debugPrint('Error verifying membership: $e');
      return null;
    }
  }

  @override
  Future<bool> updateMemberProfile(MemberModel member, {bool isDemoMode = false}) async {
    if (isDemoMode || _client == null) {
      return false;
    }

    try {
      await _client!
          .from('memberships')
          .update(member.toJson())
          .eq('membership_id', member.id);
      return true;
    } catch (e) {
      debugPrint('Error updating member: $e');
      return false;
    }
  }

  @override
  Future<List<MemberModel>> getAllMembers({bool isDemoMode = false}) async {
    if (isDemoMode || _client == null) {
      return [];
    }

    try {
      final response = await _client!.from('memberships').select();
      return (response as List).map((m) => MemberModel.fromJson(m)).toList();
    } catch (e) {
      debugPrint('Error fetching all members: $e');
      return [];
    }
  }

  @override
  Future<bool> updateMemberStatus(String memberId, String status, {bool isDemoMode = false}) async {
    if (isDemoMode || _client == null) {
      return false;
    }

    try {
      final updateData = {
        'is_active': status == 'active',
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (status == 'active') {
        updateData['activated_at'] = DateTime.now().toIso8601String();
      }
      await _client!
          .from('memberships')
          .update(updateData)
          .eq('membership_id', memberId);
      return true;
    } catch (e) {
      debugPrint('Error updating status: $e');
      return false;
    }
  }
}