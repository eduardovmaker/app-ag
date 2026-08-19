import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'routes.dart';

class ViaAuditApp extends StatelessWidget {
  final bool isLoggedIn;

  const ViaAuditApp({super.key, this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Via Audit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
