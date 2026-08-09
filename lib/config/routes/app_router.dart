import 'package:flutter/material.dart';
import '../../models/request_model.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/email_verification_screen.dart';
import '../../screens/client/client_shell.dart';
import '../../screens/client/request_detail_screen.dart';
import '../../screens/client/new_request_screen.dart';
import '../../screens/admin/admin_shell.dart';
import '../../screens/admin/admin_request_detail_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return _buildRoute(const LoginScreen(), settings);
      case '/signup':
        return _buildRoute(const SignupScreen(), settings);
      case '/verify-email':
        return _buildRoute(const EmailVerificationScreen(), settings);
      case '/client':
        return _buildRoute(const ClientShell(), settings);
      case '/admin':
        return _buildRoute(const AdminShell(), settings);
      case '/request-detail':
        final request = settings.arguments as RequestModel;
        return _buildRoute(RequestDetailScreen(request: request), settings);
      case '/new-request':
        return _buildRoute(const NewRequestScreen(), settings);
      case '/admin-request-detail':
        final request = settings.arguments as RequestModel;
        return _buildRoute(
            AdminRequestDetailScreen(request: request), settings);
      default:
        return _buildRoute(const LoginScreen(), settings);
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.03);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
