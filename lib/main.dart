import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_router.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/client/client_shell.dart';
import 'screens/admin/admin_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SyncSpaceApp());
}

class SyncSpaceApp extends StatelessWidget {
  const SyncSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'SyncSpace',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        onGenerateRoute: AppRouter.generateRoute,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // Loading state
        if (auth.isLoading) {
          return Scaffold(
            backgroundColor: const Color(0xFF0A0E21),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.sync_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'SyncSpace',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Not authenticated
        if (!auth.isAuthenticated) {
          return const LoginScreen();
        }

        // Not email verified
        if (!auth.isEmailVerified) {
          return const EmailVerificationScreen();
        }

        // Authenticated - route by role
        if (auth.isAdmin) {
          return const AdminShell();
        }

        // Handle error state (e.g. Firestore failed)
        if (auth.error != null && auth.userModel == null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 64),
                    const SizedBox(height: 24),
                    Text(
                      'Profile Error',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      auth.error!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => auth.signOut(),
                      child: const Text('Back to Login'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return const ClientShell();
      },
    );
  }
}
