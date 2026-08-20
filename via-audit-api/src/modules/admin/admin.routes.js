const express = require('express');
const router = express.Router();
const controller = require('./admin.controller');

// Middleware interno para verificar se o usuário autenticado possui role Admin
const requireAdmin = (req, res, next) => {
  if (req.user && (req.user.role === 'admin' || req.user.id === 9999)) {
    return next();
  }
  return res.status(403).json({ success: false, error: 'Acesso negado: Requer privilégios de Administrador.' });
};

router.use(requireAdmin);

router.get('/stats', controller.stats);
router.get('/reports/excel', controller.exportExcel);
router.get('/reports/pdf', controller.exportPdf);

// Rotas de Gestão de Ativos Auditáveis pelo Administrador
router.get('/escolas/:escolaId/ativos', controller.listarAtivosEscola);
router.patch('/ativos/:id/toggle-auditavel', controller.toggleAtivoAuditavel);
router.put('/escolas/:escolaId/ativos/bulk-toggle', controller.bulkToggleAtivos);

module.exports = router;
