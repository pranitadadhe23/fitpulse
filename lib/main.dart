// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'providers/providers.dart';
import 'screens/auth_screen.dart';
import 'screens/main_navigation.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.bgSurface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FitPulseApp());
}

class FitPulseApp extends StatelessWidget {
  const FitPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
      ],
      child: MaterialApp(
        title: 'FitPulse',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const AppRoot(),
        builder: (context, child) {
          // Ensure consistent text scaling
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor:
                  MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Show splash while initializing
        if (auth.status == AuthStatus.initial) {
          return const SplashScreen();
        }

        // Show main app or auth based on status
        if (auth.isAuthenticated) {
          return const MainNavigation();
        }

        return const AuthScreen();
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: AppColors.cyanGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonCyan.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bolt,
                      color: AppColors.bg,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'FITPULSE',
                    style: TextStyle(
                      color: AppColors.neonCyan,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'YOUR FUTURISTIC FITNESS COMPANION',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 60),
                  SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.neonCyan),
                      minHeight: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
