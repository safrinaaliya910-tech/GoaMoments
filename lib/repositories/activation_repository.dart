import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/activation_model.dart';
import '../services/supabase_service.dart';

abstract class ActivationRepository {
  Future<ActivationModel?> getActiveDeviceForMember(String memberId, {bool isDemoMode = false});
  Future<bool> registerDevice({
    required String memberId,
    required String deviceId,
    required String deviceModel,
    required String location,
    bool isDemoMode = false,
  });
  Future<bool> resetDeviceForMember(String memberId, {bool isDemoMode = false});
}

class ActivationRepositoryImpl implements ActivationRepository {
  final SupabaseClient? _supabaseClient;
  
  SupabaseClient? get _client => _supabaseClient ?? (SupabaseService().isDemoMode ? null : Supabase.instance.client);
  
  // Local storage for Demo Mode
  final Map<String, ActivationModel> _mockDeviceRegs = {};

  ActivationRepositoryImpl(this._supabaseClient);

  @override
  Future<ActivationModel?> getActiveDeviceForMember(String memberId, {bool isDemoMode = false}) async {
    if (isDemoMode || _client == null) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockDeviceRegs[memberId];
    }

    try {
      final response = await _client!
          .from('device_registrations')
          .select()
          .eq('member_id', memberId)
          .eq('status', 'active')
          .maybeSingle();

      if (response == null) return null;
      return ActivationModel.fromJson(response);
    } catch (e) {
      print('Error checking active device registration: $e');
      return null;
    }
  }

  @override
  Future<bool> registerDevice({
    required String memberId,
    required String deviceId,
    required String deviceModel,
    required String location,
    bool isDemoMode = false,
  }) async {
    final timestamp = DateTime.now();

    if (isDemoMode || _client == null) {
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Strict constraint check
      if (_mockDeviceRegs.containsKey(memberId) && _mockDeviceRegs[memberId]!.deviceId != deviceId) {
        // Already active on another device!
        print('Security Alert: Device registration attempt failed. Member $memberId already registered on ${_mockDeviceRegs[memberId]!.deviceId}');
        return false;
      }

      _mockDeviceRegs[memberId] = ActivationModel(
        id: 'mock-reg-id-${memberId}',
        createdAt: timestamp,
        updatedAt: timestamp,
        status: 'active',
        memberId: memberId,
        deviceId: deviceId,
        deviceModel: deviceModel,
        activationLocation: location,
        activationTimestamp: timestamp,
      );
      return true;
    }

    try {
      // Check existing active registrations
      final existing = await getActiveDeviceForMember(memberId, isDemoMode: false);
      if (existing != null && existing.deviceId != deviceId) {
        // Attempted duplicate activation on a different device
        return false;
      }

      // Upsert device registration:
      // Since member_id is unique, insert will fail or we can do upsert/update depending on policy
      final regData = {
        'member_id': memberId,
        'device_id': deviceId,
        'device_model': deviceModel,
        'activation_location': location,
        'activation_timestamp': timestamp.toIso8601String(),
        'status': 'active',
        'updated_at': timestamp.toIso8601String(),
      };

      await _client!
          .from('device_registrations')
          .upsert(regData, onConflict: 'member_id');
      
      return true;
    } catch (e) {
      print('Error registering device in database: $e');
      return false;
    }
  }

  @override
  Future<bool> resetDeviceForMember(String memberId, {bool isDemoMode = false}) async {
    if (isDemoMode || _client == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (_mockDeviceRegs.containsKey(memberId)) {
        _mockDeviceRegs.remove(memberId);
        return true;
      }
      return false;
    }

    try {
      // Admin deletes or deactivates the device registration record for the member
      await _client!
          .from('device_registrations')
          .delete()
          .eq('member_id', memberId);
      return true;
    } catch (e) {
      print('Error resetting device: $e');
      return false;
    }
  }
}
