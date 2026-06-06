import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class OtpService {
  final SupabaseClient? _supabaseClient;
  String? _simulatedOtp;

  OtpService(this._supabaseClient);

  SupabaseClient? get _client => _supabaseClient ?? (SupabaseService().isDemoMode ? null : Supabase.instance.client);

  /// Sends OTP to Email or Phone.
  /// [method] can be 'email' or 'phone'.
  /// In Demo Mode (or if client is null), it generates a simulated code.
  Future<bool> sendOtp({
    required String target,
    required String method,
    bool isDemoMode = false,
  }) async {
    if (isDemoMode || _client == null) {
      // Simulate sending OTP
      await Future.delayed(const Duration(seconds: 2));
      _simulatedOtp = "123456"; // Standard simple code for demo testing
      print('--- GOA MOMENTS: OTP Sent to $target ($method): $_simulatedOtp ---');
      return true;
    }

    try {
      if (method == 'email') {
        await _client!.auth.signInWithOtp(
          email: target,
          emailRedirectTo: 'io.supabase.goamoments://login-callback',
        );
      } else {
        await _client!.auth.signInWithOtp(
          phone: target,
        );
      }
      return true;
    } catch (e) {
      print('Error sending OTP via Supabase: $e');
      return false;
    }
  }

  /// Verifies OTP.
  /// In Demo Mode, verifies against our simulated code.
  Future<bool> verifyOtp({
    required String target,
    required String otpCode,
    required String method,
    bool isDemoMode = false,
  }) async {
    if (isDemoMode || _client == null) {
      await Future.delayed(const Duration(seconds: 1));
      return otpCode == _simulatedOtp || otpCode == "123456";
    }

    try {
      final response = await _client!.auth.verifyOTP(
        type: method == 'email' ? OtpType.email : OtpType.sms,
        email: method == 'email' ? target : null,
        phone: method == 'phone' ? target : null,
        token: otpCode,
      );
      return response.session != null;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }
}
