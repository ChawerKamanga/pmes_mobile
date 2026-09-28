import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/models/dashboard_overview.dart';
import '../core/services/api_exception.dart';
import '../core/services/auth_service.dart';
import '../core/services/dashboard_service.dart';
import '../core/services/session_provider.dart';
import '../core/theme/app_colors.dart';
import '../widgets/home/assigned_project_card.dart';
import '../widgets/home/assigned_projects_header.dart';
import '../widgets/home/custom_bottom_nav_bar.dart';
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
  static const _dashboardService = DashboardService();
  bool _isLoggingOut = false;

  Future<DashboardOverviewData>? _overviewFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _overviewFuture ??= _loadOverview();
  }

  Future<DashboardOverviewData> _loadOverview() async {
    final token = context.read<SessionProvider>().token;
    if (token == null) {
      throw const ApiException('You are not signed in.');
    }
    final response = await _dashboardService.getOverview(token: token);
    return response.data;
  }

  Future<void> _refresh() async {
    setState(() => _overviewFuture = _loadOverview());
    await _overviewFuture;
  }

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
      bottomNavigationBar: const CustomBottomNavBar(),
      body: FutureBuilder<DashboardOverviewData>(
        future: _overviewFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final message = snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'Something went wrong while loading the dashboard.';
            return _ErrorState(message: message, onRetry: _refresh);
          }

          final overview = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
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
                          value: overview.summary.assignedProjects.count,
                          label: 'Assigned Projects',
                          subLabel: overview.summary.assignedProjects.description,
                          rightWidget: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              overview.summary.assignedProjects.statusLabel,
                              style: const TextStyle(
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
                          value: overview.summary.fiscalAllocation.formattedAmount,
                          label: overview.summary.fiscalAllocation.label,
                          subLabel: overview.summary.fiscalAllocation.fiscalYear ??
                              overview.summary.fiscalAllocation.currency,
                          rightWidget: overview.summary.fiscalAllocation.percentageChange ==
                                  null
                              ? null
                              : Text(
                                  '${overview.summary.fiscalAllocation.percentageChange! >= 0 ? '+' : ''}${overview.summary.fiscalAllocation.percentageChange}%',
                                  style: const TextStyle(
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

                  KpiSummaryCard(
                    verified: overview.summary.kpiOverview.verified,
                    total: overview.summary.kpiOverview.total,
                    completionPercentage:
                        overview.summary.kpiOverview.completionPercentage,
                    nextReviewLabel: overview.summary.kpiOverview.nextReviewLabel,
                  ),
                  const SizedBox(height: 28),

                  AssignedProjectsHeader(activeCount: overview.projects.length),
                  const SizedBox(height: 16),

                  if (overview.projects.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No assigned projects yet.',
                        style: TextStyle(color: AppColors.neutral),
                      ),
                    )
                  else
                    for (final project in overview.projects) ...[
                      AssignedProjectCard(project: project),
                      const SizedBox(height: 16),
                    ],
                  const SizedBox(height: 16),

                  // Logout Button
                  HomeLogoutButton(
                    isLoggingOut: _isLoggingOut,
                    onPressed: _handleLogout,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.neutral, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.neutral),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

