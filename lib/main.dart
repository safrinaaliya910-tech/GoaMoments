import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart'; 

// Services & Repositories
import 'services/supabase_service.dart';
import 'services/location_service.dart';
import 'services/otp_service.dart';
import 'services/notification_service.dart';
import 'repositories/member_repository.dart';
import 'repositories/activation_repository.dart';
import 'repositories/content_repository.dart';

// ViewModels
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/activation_viewmodel.dart';
import 'viewmodels/content_viewmodel.dart';

// Screens
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/membership_activation_screen.dart';
import 'screens/goa_location_verification_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/device_registration_screen.dart';
import 'screens/activation_success_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/membership_card_screen.dart';
import 'screens/benefits_screen.dart';
import 'screens/support_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/sign_in_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. SAFELY LOAD ENV VARIABLES
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("CRITICAL ERROR: .env file failed to load. Ensure it is in pubspec.yaml assets.");
  }

  // 2. INITIALIZE SUPABASE
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL', fallback: 'MISSING_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY', fallback: 'MISSING_KEY'),
  );

  await SupabaseService().initialize();
  
  final supabaseService = SupabaseService();
  final locationService = LocationService();
  
  final memberRepo = MemberRepositoryImpl(null);
  final activationRepo = ActivationRepositoryImpl(null);
  final contentRepo = ContentRepositoryImpl(null);
  
  final otpService = OtpService(null);
  final notificationService = NotificationService(null);

  runApp(
    MultiProvider(
      providers: [
        Provider<SupabaseService>.value(value: supabaseService),
        Provider<LocationService>.value(value: locationService),
        Provider<OtpService>.value(value: otpService),
        Provider<NotificationService>.value(value: notificationService),
        Provider<MemberRepository>.value(value: memberRepo),
        Provider<ActivationRepository>.value(value: activationRepo),
        Provider<ContentRepository>.value(value: contentRepo),
        
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(memberRepo),
        ),
        ChangeNotifierProvider<ActivationViewModel>(
          create: (_) => ActivationViewModel(
            memberRepository: memberRepo,
            activationRepository: activationRepo,
            locationService: locationService,
            otpService: otpService,
            notificationService: notificationService,
          ),
        ),
        ChangeNotifierProvider<ContentViewModel>(
          create: (_) => ContentViewModel(contentRepo),
        ),
      ],
      child: const GoaMomentsApp(),
    ),
  );
}

class GoaMomentsApp extends StatelessWidget {
  const GoaMomentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goa Moments',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050505),
        primaryColor: const Color(0xFFCF9E2C),
        hintColor: const Color(0xFFF5D06F),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFFD4AF37),
          selectionColor: Color(0xFF554411),
          selectionHandleColor: Color(0xFFD4AF37),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/': page = const SplashScreen(); break;
          case '/welcome': page = const WelcomeScreen(); break;
          case '/activate': page = const MembershipActivationScreen(); break;
          case '/signin': page = const SignInScreen(); break;
          case '/location-verification': page = const GoaLocationVerificationScreen(); break;
          case '/otp-verification': page = const OtpVerificationScreen(); break;
          case '/device-registration': page = const DeviceRegistrationScreen(); break;
          case '/activation-success': page = const ActivationSuccessScreen(); break;
          case '/dashboard': page = const DashboardScreen(); break;
          case '/membership-card': page = const MembershipCardScreen(); break;
          case '/benefits':
  final args = settings.arguments;
  String category = 'ALL';
  bool isGuest = false;

  // This safety check prevents the crash if you pass a boolean by accident
  if (args is Map<String, dynamic>) {
    category = args['category'] ?? 'ALL';
    isGuest = args['isGuestMode'] ?? false;
  } else if (args is bool) {
    // If you accidentally pass 'true' as a boolean, the app now handles it safely
    isGuest = args;
  }
  
  page = BenefitsScreen(category: category, isGuestMode: isGuest);
  break;
          case '/support': page = const SupportScreen(); break;
          case '/profile': page = const ProfileScreen(); break;
          default: page = const SplashScreen();
        }
        
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.05, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            final slideTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(slideTween),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 450),
        );
      },
    );
  }
}