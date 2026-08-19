const { success, error } = require('../../utils/response');
const pool = require('../../config/db');
const store = require('../../database/store');

exports.login = async (req, res, next) => {
  try {
    const { pin } = req.body;

    if (!pin || typeof pin !== 'string' || !/^\d{6}$/.test(pin)) {
      return error(res, 'O PIN deve ter exatamente 6 dígitos numéricos', 400);
    }

    let orientador = null;

    try {
      const [rows] = await pool.query(
        'SELECT id, nome, ativo FROM orientadores WHERE pin = ? LIMIT 1',
        [pin]
      );
      if (rows && rows.length > 0) {
        orientador = rows[0];
      }
    } catch (e) {
      // Fallback para store em memória
      orientador = store.orientadores.find(o => o.pin === pin);
    }

    if (!orientador || orientador.ativo !== 1) {
      return error(res, 'PIN inválido ou orientador inativo', 401);
    }

    // Calcular estatísticas de escolas
    let totalEscolas = 12;
    let escolasVisitadas = 3;

    try {
      const [totRows] = await pool.query(
        'SELECT COUNT(*) as total FROM orientador_escola WHERE orientador_id = ?',
        [orientador.id]
      );
      const [visRows] = await pool.query(
        'SELECT COUNT(*) as visitadas FROM orientador_escola WHERE orientador_id = ? AND status = "concluida"',
        [orientador.id]
      );
      if (totRows && totRows.length > 0) totalEscolas = totRows[0].total || totalEscolas;
      if (visRows && visRows.length > 0) escolasVisitadas = visRows[0].visitadas || escolasVisitadas;
    } catch (e) {
      const rels = store.orientador_escola.filter(r => r.orientador_id === orientador.id);
      if (rels.length > 0) {
        totalEscolas = rels.length;
        escolasVisitadas = rels.filter(r => r.status === 'concluida').length;
      }
    }

    return success(res, {
      orientadorId: orientador.id,
      nome: orientador.nome,
      totalEscolas,
      escolasVisitadas,
    });
  } catch (err) {
    next(err);
  }
};
