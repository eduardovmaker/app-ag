import 'package:go_router/go_router.dart';
import '../screens/login/login_screen.dart';
import '../screens/escolas/lista_escolas_screen.dart';
import '../screens/checklist/checklist_escola_screen.dart';
import '../screens/registro/registro_item_screen.dart';
import '../screens/finalizar/finalizar_visita_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/schools',
      builder: (context, state) => const ListaEscolasScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/checklist',
      builder: (context, state) {
        final extraData = state.extra as Map<String, dynamic>?;
        return ChecklistEscolaScreen(extraData: extraData);
      },
    ),
    GoRoute(
      path: '/item-register',
      builder: (context, state) {
        final extraData = state.extra as Map<String, dynamic>?;
        return RegistroItemScreen(extraData: extraData);
      },
    ),
    GoRoute(
      path: '/summary',
      builder: (context, state) {
        final extraData = state.extra as Map<String, dynamic>?;
        return FinalizarVisitaScreen(extraData: extraData);
      },
    ),
  ],
);
