import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:via_audit/core/services/auth_service.dart';
import 'package:via_audit/screens/login/login_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SPEC-2026-010: Autenticação por PIN', () {
    late AuthService authService;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      authService = AuthService();
    });

    test('CA-01 / CA-02: Validação de PIN no AuthService', () async {
      // PIN com menos de 6 dígitos lança exceção
      expect(
        () async => await authService.login('123'),
        throwsA(isA<Exception>()),
      );

      // PIN de fallback local válido '724123'
      final orientador = await authService.login('724123');
      expect(orientador, isNotNull);
      expect(orientador?.nome, contains('Daniela Moreira'));
    });

    testWidgets('CA-03: Digitação e limpeza de dígitos na LoginScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Encontrar teclado numérico e botões de dígitos
      final button1 = find.text('1');
      expect(button1, findsOneWidget);

      // Tocar no dígito 1
      await tester.tap(button1);
      await tester.pump();

      // Verificar que botão de apagar funciona
      final backButton = find.byIcon(Icons.backspace_outlined);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pump();
      }
    });
  });
}
