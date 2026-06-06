import 'dart:convert';

class QrService {
  /// Generates a secure JSON string containing membership details.
  /// For enhanced security in production, this string can be encrypted or cryptographically signed.
  String generateMembershipQrData({
    required String membershipId,
    required String memberName,
    required String planName,
    required String status,
    required String activationDate,
  }) {
    final payload = {
      'membership_id': membershipId,
      'member_name': memberName,
      'plan': planName,
      'status': status,
      'activation_date': activationDate,
      'signature': _generateSecureSignature(membershipId, status), // Readiness for cryptographic validation
      'version': '1.0',
    };
    return jsonEncode(payload);
  }

  /// Verifies a QR payload. This is ready for future partner app integrations.
  Map<String, dynamic>? verifyMembershipQrData(String qrContent) {
    try {
      final Map<String, dynamic> data = jsonDecode(qrContent);
      
      // Basic check
      if (!data.containsKey('membership_id') || !data.containsKey('signature')) {
        return null;
      }

      // Verify signature matches
      final expectedSig = _generateSecureSignature(data['membership_id'], data['status']);
      final isValidSignature = data['signature'] == expectedSig;

      return {
        'isValid': isValidSignature,
        'membership_id': data['membership_id'],
        'member_name': data['member_name'],
        'plan': data['plan'],
        'status': data['status'],
        'activation_date': data['activation_date'],
      };
    } catch (e) {
      print('QR Verification error: $e');
      return null;
    }
  }

  /// Placeholder HMAC/Signature generator using a secret key
  String _generateSecureSignature(String membershipId, String status) {
    // In production, sign using an actual key/token or SHA-256 hash.
    // e.g., sha256(membershipId + status + secretKey)
    final simpleToken = "$membershipId|$status|GOA_MOMENTS_SECRET_2026";
    // Returns a dummy hash representation
    return simpleToken.hashCode.toRadixString(16).toUpperCase();
  }
}
