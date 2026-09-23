import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/services/session_provider.dart';
import 'core/theme/app_theme.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SessionProvider()..restoreSession(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final session = context.read<SessionProvider>();
    _router = GoRouter(
      initialLocation: '/login',
      refreshListenable: session,
      redirect: (context, state) {
        if (session.isLoading) return null;

        final isLoggingIn = state.matchedLocation == '/login';
        if (session.isAuthenticated && isLoggingIn) return '/home';
        if (!session.isAuthenticated && !isLoggingIn) return '/login';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
      ],
    );
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
