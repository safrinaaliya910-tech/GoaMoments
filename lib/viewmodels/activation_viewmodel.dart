import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ADDED FOR DATABASE UPDATE
import '../models/member_model.dart';
import '../repositories/member_repository.dart';
import '../repositories/activation_repository.dart';
import '../services/location_service.dart';
import '../services/otp_service.dart';
import '../services/notification_service.dart';

class ActivationViewModel extends ChangeNotifier {
  final MemberRepository _memberRepository;
  final ActivationRepository _activationRepository;
  final LocationService _locationService;
  final OtpService _otpService;
  final NotificationService _notificationService;

  bool _isLoading = false;
  String? _errorMessage;

  // Activation Flow Parameters
  MemberModel? _verifiedMember;
  Map<String, dynamic>? _locationData;
  String? _selectedOtpMethod; // 'email' or 'phone'
  String? _otpTarget;

  // Security and Warning flags
  bool _showDeviceConflictWarning = false;
  String? _conflictingDeviceId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MemberModel? get verifiedMember => _verifiedMember;
  Map<String, dynamic>? get locationData => _locationData;
  String? get selectedOtpMethod => _selectedOtpMethod;
  String? get otpTarget => _otpTarget;
  bool get showDeviceConflictWarning => _showDeviceConflictWarning;

  ActivationViewModel({
    required MemberRepository memberRepository,
    required ActivationRepository activationRepository,
    required LocationService locationService,
    required OtpService otpService,
    required NotificationService notificationService,
  })  : _memberRepository = memberRepository,
        _activationRepository = activationRepository,
        _locationService = locationService,
        _otpService = otpService,
        _notificationService = notificationService;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetActivationState() {
    _verifiedMember = null;
    _locationData = null;
    _selectedOtpMethod = null;
    _otpTarget = null;
    _showDeviceConflictWarning = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// STAGE 1: Verify Membership Details (NOW SAVES NAME TO SUPABASE)
  Future<bool> verifyMemberDetails({
    required String membershipId,
    required String name, // ADDED NAME PARAMETER
    required String email,
    required String phone,
    bool isDemoMode = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final member = await _memberRepository.verifyMembership(
        membershipId: membershipId,
        email: email,
        phone: phone,
        isDemoMode: isDemoMode,
      );

      if (member == null) {
        _errorMessage = "Invalid credentials. Membership details not found.";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (member.status == 'suspended') {
        _errorMessage = "This membership is suspended. Please contact concierge support.";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 1. Save the new Name to Supabase immediately upon verification
      if (!isDemoMode) {
        await Supabase.instance.client.from('memberships').update({
          'member_name': name,
        }).eq('membership_id', membershipId);
      }

      // 2. Update our local verified member with the new name so it shows in the UI
      _verifiedMember = member.copyWith(name: name);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "An error occurred during verification: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// STAGE 2: Goa Location Verification
  Future<bool> verifyGoaLocation({bool isDemoMode = true}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final locResult = await _locationService.verifyLocation(isDemoMode: isDemoMode);
      _locationData = locResult;

      if (!locResult['isInside']) {
        _errorMessage = locResult['details'] ?? "You must be physically present in Goa to activate this membership.";
        
        // Log the failed activation attempt
        if (_verifiedMember != null) {
          await _notificationService.logActivation(
            membershipId: _verifiedMember!.id,
            memberName: _verifiedMember!.name,
            device: await _retrieveDeviceModelString(),
            location: '${locResult['latitude']}, ${locResult['longitude']} (Failed - Outside Goa)',
            status: 'failed_location',
            isDemoMode: isDemoMode,
          );
        }

        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Failed to verify GPS location: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// STAGE 3: Send OTP
  Future<bool> triggerOtpCode({required String method, bool isDemoMode = true}) async {
    if (_verifiedMember == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _selectedOtpMethod = method;
    _otpTarget = method == 'email' ? _verifiedMember!.email : _verifiedMember!.phone;

    try {
      final success = await _otpService.sendOtp(
        target: _otpTarget!,
        method: method,
        isDemoMode: isDemoMode,
      );

      if (!success) {
        _errorMessage = "Failed to dispatch verification code. Please try again.";
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = "Error sending OTP: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// STAGE 4 & 5: Verify OTP, and perform Device Binding & Activation Logs
  Future<bool> verifyOtpAndActivate({
    required String otpCode,
    bool isDemoMode = true,
  }) async {
    if (_verifiedMember == null || _otpTarget == null || _selectedOtpMethod == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Verify OTP
      final isOtpValid = await _otpService.verifyOtp(
        target: _otpTarget!,
        otpCode: otpCode,
        method: _selectedOtpMethod!,
        isDemoMode: isDemoMode,
      );

      if (!isOtpValid) {
        _errorMessage = "Verification code is incorrect. Please try again.";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. Fetch Native Device Info
      final deviceId = await _retrieveDeviceId();
      final deviceModel = await _retrieveDeviceModelString();
      final locationStr = _locationData != null 
          ? '${_locationData!['latitude']}, ${_locationData!['longitude']}' 
          : 'Unknown';

      // 3. Register Device and Handle "One active device only" check
      final registerSuccess = await _activationRepository.registerDevice(
        memberId: _verifiedMember!.id,
        deviceId: deviceId,
        deviceModel: deviceModel,
        location: locationStr,
        isDemoMode: isDemoMode,
      );

      if (!registerSuccess) {
        // Multi-device security conflict triggered!
        _showDeviceConflictWarning = true;
        _conflictingDeviceId = deviceId;
        
        await _notificationService.logActivation(
          membershipId: _verifiedMember!.id,
          memberName: _verifiedMember!.name,
          device: '$deviceModel (Attempt ID: $deviceId)',
          location: locationStr,
          status: 'failed_device',
          isDemoMode: isDemoMode,
        );

        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 4. Update member activation status to 'active'
      final statusSuccess = await _memberRepository.updateMemberStatus(
        _verifiedMember!.id,
        'active',
        isDemoMode: isDemoMode,
      );

      if (!statusSuccess) {
        _errorMessage = "Database update error. Please contact admin.";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 5. Create final success log in activation_logs
      await _notificationService.logActivation(
        membershipId: _verifiedMember!.id,
        memberName: _verifiedMember!.name,
        device: deviceModel,
        location: locationStr,
        status: 'success',
        isDemoMode: isDemoMode,
      );

      // Refresh verification cache
      _verifiedMember = await _memberRepository.getMemberById(_verifiedMember!.id, isDemoMode: isDemoMode);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Activation error: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Helper: Retrieve Unique Device ID
  Future<String> _retrieveDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (kIsWeb) return 'web-device';
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id; // Unique hardware ID
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'ios-device-id';
      }
    } catch (_) {}
    return 'fallback-device-id-999';
  }

  // Helper: Retrieve Human-Readable Device Model String
  Future<String> _retrieveDeviceModelString() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (kIsWeb) return 'Web Browser';
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.name;
      }
    } catch (_) {}
    return 'Mobile Device';
  }
}