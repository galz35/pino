import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import 'home/rutero_home_screen.dart';
import 'route/client_portfolio_screen.dart';
import 'alerts/alerts_screen.dart';
import 'profile/profile_screen.dart';

class RuteroScreen extends StatefulWidget {
  const RuteroScreen({super.key});

  @override
  State<RuteroScreen> createState() => _RuteroScreenState();
}

class _RuteroScreenState extends State<RuteroScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = const <Widget>[
    RuteroHomeScreen(),
    ClientPortfolioScreen(),
    RuteroAlertsScreen(),
    RuteroProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Ruta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.surface,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        elevation: 0,
      ),
    );
  }
}
