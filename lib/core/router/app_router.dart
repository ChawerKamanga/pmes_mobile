import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/session_provider.dart';
import '../theme/app_theme.dart';
import '../../pages/home_page.dart';
import '../../pages/login_page.dart';

const _loginPath = '/login';
const _homePath = '/home';

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final session = context.read<SessionProvider>();

    _router = GoRouter(
      initialLocation: _loginPath,
      refreshListenable: session,
      redirect: (_, state) => _redirect(session, state),
      routes: [
        GoRoute(
          path: _loginPath,
          name: 'login',
          builder: (_, _) => const LoginPage(),
        ),
        GoRoute(
          path: _homePath,
          name: 'home',
          builder: (_, _) => const HomePage(),
        ),
      ],
    );
  }

  String? _redirect(SessionProvider session, GoRouterState state) {
    if (session.isLoading) return null;

    final isLoggingIn = state.matchedLocation == _loginPath;
    if (session.isAuthenticated) {
      return isLoggingIn ? _homePath : null;
    }
    return isLoggingIn ? null : _loginPath;
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'PMES Portal',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}