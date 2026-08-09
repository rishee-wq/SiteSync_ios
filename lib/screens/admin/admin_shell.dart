import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import 'admin_overview_screen.dart';
import 'admin_requests_screen.dart';
import 'admin_clients_screen.dart';
import 'admin_settings_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  final _screens = const [
    AdminOverviewScreen(),
    AdminRequestsScreen(),
    AdminClientsScreen(),
    AdminSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryNavy,
          border: Border(
            top: BorderSide(
              color: AppColors.cardBorder.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.accentGreen,
          unselectedItemColor: AppColors.textTertiary,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Overview',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_rounded),
              label: 'Requests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              label: 'Clients',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
