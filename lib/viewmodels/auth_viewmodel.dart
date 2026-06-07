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
  bool _isDemoMode = true;

  MemberModel? get currentMember => _currentMember;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentMember != null;
  bool get isDemoMode => _isDemoMode;

  AuthViewModel(this._memberRepository);

  /// Check Supabase native session and local storage to auto-login
  Future<void> tryAutoLogin(bool isDemoMode) async {
    _isDemoMode = isDemoMode;
    _isLoading = true;
    notifyListeners();

    try {
      if (!_isDemoMode) {
        // 1. Check if Supabase already holds a valid, encrypted session
        final session = _supabaseService.auth.currentSession;
        
        if (session != null) {
          // If Supabase says we are logged in, grab the local member ID to fetch profile
          final savedMemberId = await _secureStorage.read(key: 'auth_member_id');
          if (savedMemberId != null) {
            await _loadMemberProfile(savedMemberId);
          }
        } else {
          await clearSession();
        }
      } else {
        // 2. DEMO MODE LOGIC (Your existing offline logic)
        final savedMemberId = await _secureStorage.read(key: 'auth_member_id');
        if (savedMemberId != null) {
          await _loadMemberProfile(savedMemberId);
        }
      }
    } catch (e) {
      debugPrint('Auto-login error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Helper to fetch the member from repository and validate status
  Future<void> _loadMemberProfile(String memberId) async {
    final member = await _memberRepository.getMemberById(memberId, isDemoMode: _isDemoMode);
    if (member != null && member.status == 'active') {
      _currentMember = member;
    } else {
      await clearSession(); // Member suspended or not found
    }
  }

  // =====================================================================
  // SUPABASE EMAIL OTP INTEGRATION
  // =====================================================================

  /// Sends a 6-digit OTP to the provided email address
  Future<bool> sendEmailOTP(String email) async {
    if (_isDemoMode) return true; // Pretend it worked in demo mode
    
    _isLoading = true;
    notifyListeners();

    try {
      await _supabaseService.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true, // Creates a new user if they don't exist yet
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

  /// Verifies the 6-digit OTP entered by the user
  Future<bool> verifyEmailOTP(String email, String otp, MemberModel verifiedMember) async {
    if (_isDemoMode) {
      // Offline Demo: Just set the session if OTP is '123456'
      if (otp == '123456') {
        await setSession(verifiedMember);
        return true;
      }
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final AuthResponse res = await _supabaseService.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: otp,
      );

      if (res.session != null) {
        // OTP was correct and Supabase generated a secure session!
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

  // =====================================================================

  /// Sets the logged-in member session securely
  Future<void> setSession(MemberModel member) async {
    _currentMember = member;
    await _secureStorage.write(key: 'auth_member_id', value: member.id);
    await _secureStorage.write(key: 'auth_login_time', value: DateTime.now().toIso8601String());
    notifyListeners();
  }

  /// Clear session securely (Logout)
  Future<void> clearSession() async {
    _currentMember = null;
    await _secureStorage.delete(key: 'auth_member_id');
    await _secureStorage.delete(key: 'auth_login_time');
    
    // Also sign out of Supabase
    if (!_isDemoMode) {
      try {
        await _supabaseService.auth.signOut();
      } catch (e) {
        debugPrint('Supabase SignOut Error: $e');
      }
    }
    
    notifyListeners();
  }

  /// Force refresh profile data
  Future<void> refreshProfile() async {
    if (_currentMember == null) return;
    final updated = await _memberRepository.getMemberById(_currentMember!.id, isDemoMode: _isDemoMode);
    if (updated != null) {
      _currentMember = updated;
      notifyListeners();
    }
  }

  /// Updates profile metadata (NOW CONNECTED TO SUPABASE)
  Future<bool> updateProfile({required String name, required String email, required String phone}) async {
    if (_currentMember == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Update Supabase Database directly first
      if (!_isDemoMode) {
        await Supabase.instance.client.from('memberships').update({
          'member_name': name,
          'email': email,
          'phone_number': phone,
        }).eq('id', _currentMember!.id);
      }

      // 2. Update local state
      final updated = _currentMember!.copyWith(
        name: name,
        email: email,
        phone: phone,
      );

      // 3. Keep local repository in sync
      final success = await _memberRepository.updateMemberProfile(updated, isDemoMode: _isDemoMode);
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