import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/services/auth_service.dart';
import '../core/services/session_provider.dart';
import '../core/theme/app_colors.dart';
import '../widgets/home/field_command_card.dart';
import '../widgets/home/home_app_bar.dart';
import '../widgets/home/home_logout_button.dart';
import '../widgets/home/home_stat_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _authService = AuthService();
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    final session = context.read<SessionProvider>();
    final token = session.token;
    if (token != null) {
      try {
        await _authService.logout(token: token);
      } catch (_) {}
    }
    await session.signOut();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    // Using a nested Scaffold to maintain the AppBar styling while changing the body color
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HomeAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const FieldCommandCard(),
            const SizedBox(height: 20),

            // --- Stats Row ---
            Row(
              children: [
                // Assigned Projects
                Expanded(
                  child: HomeStatCard(
                    icon: Icons.assignment_outlined,
                    iconColor: AppColors.primary,
                    value: '2',
                    label: 'Assigned Projects',
                    subLabel: 'All active in sector',
                    rightWidget: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Live',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Fiscal Allocation
                Expanded(
                  child: HomeStatCard(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: Colors.blue,
                    value: '5.7B',
                    label: 'MWK Total Fiscal',
                    subLabel: '2024/25 Allocation',
                    rightWidget: const Text(
                      '+52.5%',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            HomeLogoutButton(
              isLoggingOut: _isLoggingOut,
              onPressed: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }
}
