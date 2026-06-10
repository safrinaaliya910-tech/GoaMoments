import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart'; 
import '../models/member_model.dart';
import '../services/supabase_service.dart';

abstract class MemberRepository {
  Future<MemberModel?> getMemberById(String id, {bool isDemoMode = false});
  Future<MemberModel?> verifyMembership({
    required String membershipId,
    required String email,
    required String phone,
    String? memberName, 
    bool isDemoMode = false,
  });
  Future<bool> updateMemberProfile(MemberModel member, {bool isDemoMode = false});
  Future<List<MemberModel>> getAllMembers({bool isDemoMode = false});
  Future<bool> updateMemberStatus(String memberId, String status, {bool isDemoMode = false});
}

class MemberRepositoryImpl implements MemberRepository {
  final SupabaseClient? _supabaseClient;
  final _uuid = const Uuid(); 
  
  SupabaseClient? get _client => _supabaseClient ?? (SupabaseService().isDemoMode ? null : Supabase.instance.client);

  MemberRepositoryImpl(this._supabaseClient);

  @override
  Future<MemberModel?> getMemberById(String id, {bool isDemoMode = false}) async {
    if (isDemoMode || _client == null) return null; 

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
    String? memberName,
    bool isDemoMode = false,
  }) async {
    if (isDemoMode || _client == null) return null;

    try {
      debugPrint("🔍 Checking if user is already active in 'memberships'...");
      
      final existingAppUser = await _client!
          .from('memberships')
          .select()
          .eq('membership_id', membershipId.trim())
          .maybeSingle();

      if (existingAppUser != null) {
        debugPrint("ℹ️ User record exists in app table.");
        return MemberModel.fromJson(existingAppUser);
      }

      debugPrint("🔍 User not in app yet. Checking 'members' table from website...");

      final websiteUser = await _client!
          .from('members')
          .select()
          .eq('id', membershipId.trim())
          .maybeSingle();

      if (websiteUser == null) {
        debugPrint("🔴 FAILED: Membership ID not found in website purchases.");
        return null;
      }

      final dbEmail = (websiteUser['email'] ?? '').toString().trim().toLowerCase();
      final dbPhone = (websiteUser['phone'] ?? '').toString().trim();
      final inputEmail = email.trim().toLowerCase();
      final inputPhone = phone.trim();

      if (dbEmail != inputEmail || dbPhone != inputPhone) {
         debugPrint("🔴 FAILED: Email or Phone mismatch with website records.");
         return null;
      }

      debugPrint("✅ Verification Passed! Creating record as PENDING (is_active: false)...");

      final newAppMember = {
        'id': _uuid.v4(), 
        'membership_id': websiteUser['id'],
        'email': websiteUser['email'],
        'phone_number': websiteUser['phone'],
        'member_name': websiteUser['name'],
        'is_active': false, // Strictly false until OTP success
        'activated_at': null, 
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      await _client!.from('memberships').insert(newAppMember);

      return MemberModel.fromJson(newAppMember);
      
    } catch (e) {
      debugPrint('Error verifying/migrating membership: $e');
      return null;
    }
  }

  @override
  Future<bool> updateMemberProfile(MemberModel member, {bool isDemoMode = false}) async {
    if (isDemoMode || _client == null) return false; 

    try {
      // 🟢 Added .select() to verify the database actually updated the rows
      final List response = await _client!
          .from('memberships') 
          .update({
             'member_name': member.name,
             'email': member.email,
             'phone_number': member.phone,
             'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('membership_id', member.id)
          .select(); 

      if (response.isEmpty) {
        debugPrint("🔴 CRITICAL: Database blocked the Profile Update! Check RLS Policies.");
        return false;
      }

      debugPrint("✅ Profile successfully updated in App Database!");
      return true;
    } catch (e) {
      debugPrint('🔴 Error updating member profile: $e');
      return false;
    }
  }

  @override
  Future<List<MemberModel>> getAllMembers({bool isDemoMode = false}) async {
    if (isDemoMode || _client == null) return []; 

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
    if (isDemoMode || _client == null) return false; 

    try {
      final bool activateNow = status == 'active';

      final updateData = {
        'is_active': activateNow, 
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      if (activateNow) {
        updateData['activated_at'] = DateTime.now().toUtc().toIso8601String();
      }
      
      // 1. Turn the app's 'memberships' row to TRUE
      // 🟢 Added .select() to force a verification check
      final List response1 = await _client!
          .from('memberships') 
          .update(updateData)
          .eq('membership_id', memberId)
          .select(); 

      if (response1.isEmpty) {
        debugPrint("🔴 CRITICAL: Supabase SILENTLY BLOCKED the 'memberships' update. Run the Master SQL Script!");
        return false; // Force the app to stop and show an error!
      }

      // 2. Update the website's 'members' table to active
      if (activateNow) {
        final List response2 = await _client!
            .from('members')
            .update({'status': 'active'})
            .eq('id', memberId)
            .select();

        if (response2.isEmpty) {
           debugPrint("🔴 CRITICAL: Supabase SILENTLY BLOCKED the 'members' update. Run the Master SQL Script!");
           return false;
        }
        
        debugPrint("🟢 BOOM! Database synced! App and Website tables are both exactly marked ACTIVE.");
      }

      return true;
    } catch (e) {
      debugPrint('Error updating status: $e');
      return false;
    }
  }
}