import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/connectivity_provider.dart';
import 'core/services/location_provider.dart';
import 'core/services/session_provider.dart';
import 'core/services/appearance_settings_provider.dart';
import 'core/repositories/field_log_repository.dart';
import 'core/services/sync_service.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SessionProvider()..restoreSession(),
        ),
        ChangeNotifierProvider(
          create: (_) => AppearanceSettingsProvider()..load(),
        ),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProxyProvider2<
          ConnectivityProvider,
          SessionProvider,
          SyncService
        >(
          lazy: false,
          create: (_) => SyncService(repository: FieldLogRepository()),
          update: (_, connectivity, session, syncService) => syncService!
            ..updateDependencies(
              isOnline: connectivity.isOnline,
              token: session.token,
            ),
        ),
      ],
      child: const AppRouter(),
    );
  }
}
