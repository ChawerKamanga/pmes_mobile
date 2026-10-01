import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/connectivity_provider.dart';
import 'core/services/location_provider.dart';
import 'core/services/session_provider.dart';
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
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: const AppRouter(),
    );
  }
}
