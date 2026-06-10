import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  String? _selectedOtpMethod; 
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

  /// STAGE 1: Verify Membership Details
  Future<bool> verifyMemberDetails({
    required String membershipId,
    required String name, 
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
        memberName: name, 
        isDemoMode: false, 
      );

      if (member == null) {
        _errorMessage = "Invalid credentials. Membership details not found or do not match.";
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

      await Supabase.instance.client.from('members').update({
        'name': name, 
      }).eq('id', membershipId.trim());

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
        
        if (_verifiedMember != null) {
          await _notificationService.logActivation(
            membershipId: _verifiedMember!.id,
            memberName: _verifiedMember!.name,
            device: await _retrieveDeviceModelString(),
            location: '${locResult['latitude']}, ${locResult['longitude']} (Failed - Outside Goa)',
            status: 'failed_location',
            isDemoMode: false, 
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
        isDemoMode: false, 
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

  /// STAGE 4 & 5: Verify OTP and Activate Database
  Future<bool> verifyOtpAndActivate({
    required String otpCode,
    bool isDemoMode = true,
  }) async {
    if (_verifiedMember == null || _otpTarget == null || _selectedOtpMethod == null) {
      debugPrint("❌ ERROR: Missing verification data.");
      return false;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint("🟢 STAGE 4: Verifying OTP...");
      final isOtpValid = await _otpService.verifyOtp(
        target: _otpTarget!,
        otpCode: otpCode,
        method: _selectedOtpMethod!,
        isDemoMode: false,
      );

      if (!isOtpValid) {
        _errorMessage = "Verification code is incorrect.";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 🟢 THE FIX: FLIP THE DATABASE TO ACTIVE IMMEDIATELY!
      // We do not wait for device registration. The DB gets updated right now.
      debugPrint("🟢 STAGE 5: OTP Valid! ATTEMPTING STATUS UPDATE FOR: ${_verifiedMember!.id}");
      
      final statusSuccess = await _memberRepository.updateMemberStatus(
        _verifiedMember!.id,
        'active', // This flips both tables to TRUE
        isDemoMode: false,
      );

      if (!statusSuccess) {
        debugPrint("🔴 ERROR: Database failed to flip status to ACTIVE.");
        _errorMessage = "Database update error. Please contact admin.";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      debugPrint("✅ SUCCESS: Database marked as ACTIVE.");

      // Refresh cache so the Dashboard immediately knows the user is active
      _verifiedMember = await _memberRepository.getMemberById(_verifiedMember!.id, isDemoMode: false);
      
      // Do Device Registration quietly in the background so it never blocks the app
      _registerDeviceSilently();

      _isLoading = false;
      notifyListeners();
      return true; // Triggers navigation to the Dashboard!
    } catch (e) {
      debugPrint("🔴 CRITICAL FAILURE IN ACTIVATION: $e");
      _errorMessage = "Activation error: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 🟢 Helper function to do device setup without crashing the activation
  Future<void> _registerDeviceSilently() async {
    try {
      final deviceId = await _retrieveDeviceId();
      final deviceModel = await _retrieveDeviceModelString();
      final locationStr = _locationData != null 
          ? '${_locationData!['latitude']}, ${_locationData!['longitude']}' 
          : 'Unknown';

      await _activationRepository.registerDevice(
        memberId: _verifiedMember!.id,
        deviceId: deviceId,
        deviceModel: deviceModel,
        location: locationStr,
        isDemoMode: false,
      );

      await _notificationService.logActivation(
        membershipId: _verifiedMember!.id,
        memberName: _verifiedMember!.name,
        device: deviceModel,
        location: locationStr,
        status: 'success',
        isDemoMode: false,
      );
    } catch (e) {
      debugPrint("Silently caught device registration error: $e");
    }
  }

  Future<String> _retrieveDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (kIsWeb) return 'web-device';
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'ios-device-id';
      }
    } catch (_) {}
    return 'fallback-device-id-999';
  }

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