import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/session_provider.dart';
import '../theme/app_theme.dart';
import '../models/dashboard_overview.dart';
import '../../pages/home_page.dart';
import '../../pages/project_document_upload_page.dart';
import '../../pages/project_gps_update_page.dart';
import '../../pages/login_page.dart';
import '../../pages/project_map_page.dart';

const _loginPath = '/login';
const _homePath = '/home';
const _projectMapPath = '/home/project-map';
const _projectGpsUpdatePath = '/home/project-map/update-gps';
const _projectDocumentUploadPath = '/home/project-document-upload';

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
        GoRoute(
          path: _projectMapPath,
          name: 'project-map',
          builder: (_, state) {
            final location = state.extra;
            if (location is! ProjectLocation) {
              return const Scaffold(
                body: Center(
                  child: Text('Project map is unavailable for this item.'),
                ),
              );
            }
            return ProjectMapPage(location: location);
          },
        ),
        GoRoute(
          path: _projectGpsUpdatePath,
          name: 'project-gps-update',
          builder: (_, state) {
            final args = state.extra;
            if (args is! ProjectGpsUpdateArgs) {
              return const Scaffold(
                body: Center(
                  child: Text('Unable to open GPS update for this project.'),
                ),
              );
            }
            return ProjectGpsUpdatePage(args: args);
          },
        ),
        GoRoute(
          path: _projectDocumentUploadPath,
          name: 'project-document-upload',
          builder: (_, state) {
            final projects = state.extra;
            if (projects is! List<AssignedProject>) {
              return const Scaffold(
                body: Center(child: Text('Unable to load assigned projects.')),
              );
            }
            return ProjectDocumentUploadPage(projects: projects);
          },
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
