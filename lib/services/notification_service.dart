import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class NotificationService {
  final SupabaseClient? _supabaseClient;
  final List<Map<String, dynamic>> _localLogs = []; // Temporary log holder for Demo Mode

  NotificationService(this._supabaseClient);

  SupabaseClient? get _client => _supabaseClient ?? (SupabaseService().isDemoMode ? null : Supabase.instance.client);

  List<Map<String, dynamic>> get localLogs => _localLogs;

  /// Logs a membership activation event.
  /// If live, saves to Supabase `activation_logs`.
  /// If demo, logs to console and stores in a local list.
  /// Prepares hooks for future SMTP/email notifications.
  Future<bool> logActivation({
    required String membershipId,
    required String memberName,
    required String device,
    required String location,
    required String status, // 'success', 'failed_location', 'failed_device'
    bool isDemoMode = false,
  }) async {
    final timestamp = DateTime.now();

    final logData = {
      'membership_id': membershipId,
      'member_name': memberName,
      'device': device,
      'location': location,
      'status': status,
      'activation_time': timestamp.toIso8601String(),
    };

    if (isDemoMode || _client == null) {
      _localLogs.add(logData);
      print('--- GOA MOMENTS ACTIVATION LOG TRIGGERED ---');
      print('Member Name: $memberName');
      print('Membership ID: $membershipId');
      print('Device: $device');
      print('Location: $location');
      print('Timestamp: $timestamp');
      print('Status: $status');
      print('-------------------------------------------');

      // Hook point for future email notification in Demo Mode
      await _triggerFutureEmailNotification(logData);
      return true;
    }

    try {
      await _client!.from('activation_logs').insert(logData);

      // Hook point for future email notification in Production Mode
      await _triggerFutureEmailNotification(logData);
      return true;
    } catch (e) {
      print('Failed to write activation log to Supabase: $e');
      return false;
    }
  }

  /// Hook method to be connected with SendGrid, Mailgun, or AWS SES.
  Future<void> _triggerFutureEmailNotification(Map<String, dynamic> logData) async {
    print('--- EMAIL NOTIFICATION HOOK: Ready to send activation alert for ${logData['member_name']} ---');
    // Integration logic goes here:
    // HTTP POST to SendGrid/Mailgun API or Supabase Edge Function
    // final response = await http.post(Uri.parse('https://your-edge-function.supabase.co/send-email'), body: jsonEncode(logData));
  }

  /// Retrieve activation history (for admin views)
  Future<List<Map<String, dynamic>>> fetchActivationLogs({bool isDemoMode = false}) async {
    if (isDemoMode || _client == null) {
      return _localLogs;
    }

    try {
      final response = await _client!
          .from('activation_logs')
          .select()
          .order('activation_time', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching activation logs: $e');
      return [];
    }
  }
}
