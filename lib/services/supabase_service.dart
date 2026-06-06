import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config.dart' as config;

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isDemoMode = config.isDemoMode;
  SupabaseClient? _client;

  bool get isDemoMode => config.isDemoMode ? true : _isDemoMode;
  
  SupabaseClient get client {
    if ((config.isDemoMode ? true : _isDemoMode) || _client == null) {
      throw Exception('Supabase client is not available in Demo Mode.');
    }
    return _client!;
  }

  // NEW: Quick access to the Auth engine
  GoTrueClient get auth => client.auth;

  Future<void> initialize() async {
    if (config.isDemoMode) {
      _isDemoMode = true;
      debugPrint('--- GOA MOMENTS: Running in LUXURY OFFLINE DEMO MODE (Forced by Switch) ---');
      return;
    }
    try {
      // Load environment variables
      await dotenv.load(fileName: ".env");

      final url = dotenv.maybeGet('SUPABASE_URL');
      final anonKey = dotenv.maybeGet('SUPABASE_ANON_KEY');

      if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
        // Fallback to Demo Mode
        _isDemoMode = true;
        debugPrint('--- GOA MOMENTS: Running in LUXURY OFFLINE DEMO MODE (Missing Env Variables) ---');
        return;
      }

      // Initialize Supabase
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
      );

      _client = Supabase.instance.client;
      _isDemoMode = false;
      debugPrint('--- GOA MOMENTS: Supabase Initialized Successfully ---');
    } catch (e) {
      // Graceful fallback to Demo Mode on any configuration error
      _isDemoMode = true;
      debugPrint('--- GOA MOMENTS: Initialization failed. Falling back to DEMO MODE. Error: $e ---');
    }
  }
}