const { success, error } = require('../../utils/response');
const pool = require('../../config/db');
const store = require('../../database/store');

exports.iniciar = async (req, res, next) => {
  try {
    const orientadorId = req.user ? req.user.id : parseInt(req.body.orientadorId, 10);
    const escolaId = parseInt(req.body.escolaId, 10);

    if (!orientadorId || !escolaId) {
      return error(res, 'orientadorId e escolaId sao obrigatorios', 400);
    }

    let visitaId = null;

    try {
      const [existing] = await pool.query(
        'SELECT id FROM visitas WHERE orientador_id = ? AND escola_id = ? AND status = "em_andamento" LIMIT 1',
        [orientadorId, escolaId]
      );
      if (existing && existing.length > 0) {
        visitaId = existing[0].id;
      } else {
        const [result] = await pool.query(
          'INSERT INTO visitas (orientador_id, escola_id, status, iniciada_em) VALUES (?, ?, "em_andamento", NOW())',
          [orientadorId, escolaId]
        );
        visitaId = result.insertId;
      }
      await pool.query(
        'UPDATE orientador_escola SET status = "em_andamento" WHERE orientador_id = ? AND escola_id = ? AND status != "concluida"',
        [orientadorId, escolaId]
      );
    } catch (e) {
      // Fallback em memória com suporte a comparação numérica frouxa
      let existing = store.visitas.find(v => v.orientador_id == orientadorId && v.escola_id == escolaId && v.status === 'em_andamento');
      if (existing) {
        visitaId = existing.id;
      } else {
        visitaId = Date.now();
        store.visitas.push({
          id: visitaId,
          orientador_id: parseInt(orientadorId),
          escola_id: parseInt(escolaId),
          status: 'em_andamento',
          iniciada_em: new Date()
        });
      }
      const oe = store.orientador_escola.find(r => r.orientador_id == orientadorId && r.escola_id == escolaId);
      if (oe && oe.status !== 'concluida') {
        oe.status = 'em_andamento';
      }
    }

    return success(res, { visitaId });
  } catch (err) {
    next(err);
  }
};

exports.concluir = async (req, res, next) => {
  try {
    const visitaId = parseInt(req.params.visitaId, 10);
    const { observacaoGeral, escolaId } = req.body;
    const targetEscolaId = escolaId ? parseInt(escolaId, 10) : null;
    const orientadorId = req.user ? req.user.id : null;
    const assinaturaFile = req.file;

    const assinaturaUrl = assinaturaFile ? `/uploads/assinaturas/${assinaturaFile.filename}` : null;

    // Atualizar visita e status da escola
    try {
      await pool.query(
        'UPDATE visitas SET status = "concluida", concluida_em = NOW(), assinatura_url = ?, observacao_geral = ? WHERE id = ?',
        [assinaturaUrl, observacaoGeral || '', visitaId]
      );
      if (targetEscolaId) {
        await pool.query(
          'UPDATE orientador_escola SET status = "concluida" WHERE escola_id = ?',
          [targetEscolaId]
        );
      } else {
        const [vRows] = await pool.query('SELECT escola_id, orientador_id FROM visitas WHERE id = ?', [visitaId]);
        if (vRows && vRows.length > 0) {
          await pool.query(
            'UPDATE orientador_escola SET status = "concluida" WHERE orientador_id = ? AND escola_id = ?',
            [vRows[0].orientador_id, vRows[0].escola_id]
          );
        }
      }
    } catch (e) {
      let eId = targetEscolaId;
      const v = store.visitas.find(x => x.id == visitaId);
      if (v) {
        v.status = 'concluida';
        v.concluida_em = new Date();
        v.assinatura_url = assinaturaUrl;
        v.observacao_geral = observacaoGeral || '';
        if (!eId) eId = v.escola_id;
      }

      if (eId) {
        store.orientador_escola.forEach(r => {
          if (r.escola_id == eId) {
            if (!orientadorId || r.orientador_id == orientadorId) {
              r.status = 'concluida';
            }
          }
        });
      }
    }

    // Calcular resumo de registros
    const regs = store.registros.filter(r => r.visita_id == visitaId);
    const encontrados = regs.filter(r => r.status === 'ok').length;
    const divergentes = regs.filter(r => r.status === 'avariado').length;
    const naoEncontrados = regs.filter(r => r.status === 'nao_encontrado').length;
    const extras = regs.filter(r => r.status === 'extra').length;
    const totalConferidos = regs.length;

    return success(res, {
      visitaId,
      resumo: {
        encontrados,
        divergentes,
        naoEncontrados,
        extras,
        totalConferidos
      }
    });
  } catch (err) {
    next(err);
  }
};

exports.resumo = async (req, res, next) => {
  try {
    const visitaId = parseInt(req.params.visitaId, 10);
    const regs = store.registros.filter(r => r.visita_id == visitaId);

    const encontrados = regs.filter(r => r.status === 'ok').length;
    const divergentes = regs.filter(r => r.status === 'avariado').length;
    const naoEncontrados = regs.filter(r => r.status === 'nao_encontrado').length;
    const extras = regs.filter(r => r.status === 'extra').length;

    return success(res, {
      visitaId,
      registros: regs,
      resumo: {
        encontrados,
        divergentes,
        naoEncontrados,
        extras,
        totalConferidos: regs.length
      }
    });
  } catch (err) {
    next(err);
  }
};
