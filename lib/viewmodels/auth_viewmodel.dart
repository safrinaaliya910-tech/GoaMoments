import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/member_model.dart';
import '../repositories/member_repository.dart';
import '../services/supabase_service.dart';

class AuthViewModel extends ChangeNotifier {
  final MemberRepository _memberRepository;
  final _secureStorage = const FlutterSecureStorage();
  final _supabaseService = SupabaseService();

  MemberModel? _currentMember;
  bool _isLoading = false;
  
  bool _isDemoMode = false; 

  MemberModel? get currentMember => _currentMember;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentMember != null;
  bool get isDemoMode => _isDemoMode;

  AuthViewModel(this._memberRepository);

  Future<void> tryAutoLogin(bool isDemoModeParam) async {
    _isDemoMode = isDemoModeParam; 
    _isLoading = true;
    notifyListeners();

    try {
      final savedMemberId = await _secureStorage.read(key: 'auth_member_id');
      
      if (savedMemberId != null) {
        debugPrint("🟢 AUTO-LOGIN: Found saved ID $savedMemberId. Fetching profile...");
        await _loadMemberProfile(savedMemberId);
      } else {
        debugPrint("ℹ️ AUTO-LOGIN: No saved session found.");
        await clearSession();
      }
    } catch (e) {
      debugPrint('Auto-login error: $e');
      await clearSession();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadMemberProfile(String memberId) async {
    final member = await _memberRepository.getMemberById(memberId, isDemoMode: false);
    if (member != null && member.status == 'active') {
      _currentMember = member;
      debugPrint("✅ PROFILE LOADED: Welcome back, ${member.name}");
    } else {
      debugPrint("🔴 PROFILE LOAD FAILED: Member not found or not active.");
      await clearSession(); 
    }
  }

  Future<bool> sendEmailOTP(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabaseService.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Send OTP Error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyEmailOTP(String email, String otp, MemberModel verifiedMember) async {
    _isLoading = true;
    notifyListeners();

    try {
      final AuthResponse res = await _supabaseService.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: otp,
      );

      if (res.session != null) {
        await setSession(verifiedMember);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Verify OTP Error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> setSession(MemberModel member) async {
    _currentMember = member;
    await _secureStorage.write(key: 'auth_member_id', value: member.id);
    await _secureStorage.write(key: 'auth_login_time', value: DateTime.now().toIso8601String());
    debugPrint("✅ SESSION SECURED: ${member.id} is now logged in persistently.");
    notifyListeners();
  }

  Future<void> clearSession() async {
    _currentMember = null;
    await _secureStorage.delete(key: 'auth_member_id');
    await _secureStorage.delete(key: 'auth_login_time');
    
    try {
      await _supabaseService.auth.signOut();
    } catch (e) {
      debugPrint('Supabase SignOut Error: $e');
    }
    
    debugPrint("🔴 SESSION CLEARED: User logged out.");
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (_currentMember == null) return;
    final updated = await _memberRepository.getMemberById(_currentMember!.id, isDemoMode: false);
    if (updated != null) {
      _currentMember = updated;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({required String name, required String email, required String phone}) async {
    if (_currentMember == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      await Supabase.instance.client.from('memberships').update({
        'member_name': name,
        'email': email,
        'phone_number': phone,
      }).eq('membership_id', _currentMember!.id); 

      final updated = _currentMember!.copyWith(
        name: name,
        email: email,
        phone: phone,
      );

      final success = await _memberRepository.updateMemberProfile(updated, isDemoMode: false);
      if (success) {
        _currentMember = updated;
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('Profile Update Error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}