import 'package:flutter_test/flutter_test.dart';
import 'package:via_audit/features/audit/providers/audit_provider.dart';

void main() {
  group('SPEC-2026-020: Gestão e Listagem de Escolas', () {
    late AuditProvider provider;

    setUp(() {
      provider = AuditProvider();
    });

    test('CA-01 / CA-03: Lista inicial de escolas e contagem de ativos', () {
      expect(provider.schools.length, greaterThanOrEqualTo(2));
      final escola = provider.schools.first;
      expect(escola.name, contains('Maria José da Silva'));
      expect(escola.totalAssets, equals(9));
      expect(escola.visitedAssets, equals(5));
    });
  });
}
