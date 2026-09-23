import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/services/auth_service.dart';
import '../core/services/session_provider.dart';
import '../core/theme/app_colors.dart';
import '../widgets/home/assigned_project_card.dart';
import '../widgets/home/assigned_projects_header.dart';
import '../widgets/home/field_command_card.dart';
import '../widgets/home/home_app_bar.dart';
import '../widgets/home/home_logout_button.dart';
import '../widgets/home/home_stat_card.dart';
import '../widgets/home/kpi_summary_card.dart';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HomeAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Field Command Dark Card ---
            const FieldCommandCard(),
            const SizedBox(height: 16),

            // --- Stats Row (Assigned Projects & Fiscal Allocation) ---
            Row(
              children: [
                Expanded(
                  child: HomeStatCard(
                    icon: Icons.folder_outlined,
                    iconColor: AppColors.secondary,
                    value: '2',
                    label: 'Assigned Projects',
                    subLabel: 'All active in sector',
                    rightWidget: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Live',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HomeStatCard(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppColors.secondary,
                    value: '5.7B',
                    label: 'MWK Total Fiscal',
                    subLabel: '2024/25 Allocation',
                    rightWidget: const Text(
                      '+52.5%',
                      style: TextStyle(
                        color: AppColors.neutralDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            const KpiSummaryCard(),
            const SizedBox(height: 28),

            const AssignedProjectsHeader(),
            const SizedBox(height: 16),

            const AssignedProjectCard(),
            const SizedBox(height: 32),

            // Logout Button
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
