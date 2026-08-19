import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'core/db/local_db.dart';
import 'core/services/auth_service.dart';
import 'core/services/sync_service.dart';
import 'features/audit/providers/audit_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mobile-only portrait orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Translucent status bar with dark icons
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Inicializar banco local SQLite
  await LocalDb.database;

  // Verificar persistência de sessão
  final authService = AuthService();
  final savedId = await authService.getSavedOrientadorId();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuditProvider()),
        ChangeNotifierProvider(create: (_) => SyncService()),
      ],
      child: ViaAuditApp(isLoggedIn: savedId != null),
    ),
  );
}
