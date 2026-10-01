import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/session_provider.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessionProvider()..restoreSession(),
      child: const AppRouter(),
    );
  }
}
