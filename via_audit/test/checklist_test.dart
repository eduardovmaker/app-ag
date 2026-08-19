import 'package:flutter_test/flutter_test.dart';
import 'package:via_audit/features/audit/providers/audit_provider.dart';

void main() {
  group('SPEC-2026-030 & SPEC-2026-040: Checklist e Registro de Ativos', () {
    late AuditProvider provider;

    setUp(() {
      provider = AuditProvider();
    });

    test('CA-01 / CA-02: Alternância de status de ativo e progresso', () {
      expect(provider.checklistItems.length, greaterThan(0));

      // Selecionar e atualizar status do item atual para 'done'
      provider.selectItem(0);
      provider.updateCurrentItemStatus('done');
      expect(provider.currentItem.status, equals('done'));
      expect(provider.completedCount, greaterThan(0));
    });
  });
}
