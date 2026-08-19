const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { success, error } = require('../../utils/response');
const pool = require('../../config/db');
const store = require('../../database/store');

const JWT_SECRET = process.env.JWT_SECRET || 'via-audit-sec-key-2026';

exports.login = async (req, res, next) => {
  try {
    const { pin } = req.body;

    if (!pin || typeof pin !== 'string' || !/^\d{6}$/.test(pin)) {
      return error(res, 'O PIN deve ter exatamente 6 dígitos numéricos', 400);
    }

    let orientador = null;

    try {
      const [rows] = await pool.query(
        'SELECT id, nome, pin, role, ativo FROM orientadores'
      );
      if (rows && rows.length > 0) {
        orientador = rows.find(o => bcrypt.compareSync(pin, o.pin) || o.pin === pin);
      }
    } catch (e) {
      // Fallback para store em memória com suporte a bcrypt e plaintext fallback
      orientador = store.orientadores.find(o => bcrypt.compareSync(pin, o.pin) || o.pin === pin);
    }

    if (!orientador || orientador.ativo !== 1) {
      return error(res, 'PIN inválido ou orientador inativo', 401);
    }

    const userRole = orientador.role || (orientador.id === 9999 ? 'admin' : 'orientador');

    // Calcular estatísticas de escolas
    let totalEscolas = 0;
    let escolasVisitadas = 0;

    try {
      const [totRows] = await pool.query(
        'SELECT COUNT(*) as total FROM orientador_escola WHERE orientador_id = ?',
        [orientador.id]
      );
      const [visRows] = await pool.query(
        'SELECT COUNT(*) as visitadas FROM orientador_escola WHERE orientador_id = ? AND status = "concluida"',
        [orientador.id]
      );
      if (totRows && totRows.length > 0) totalEscolas = totRows[0].total || 0;
      if (visRows && visRows.length > 0) escolasVisitadas = visRows[0].visitadas || 0;
    } catch (e) {
      const rels = store.orientador_escola.filter(r => r.orientador_id === orientador.id);
      totalEscolas = rels.length;
      escolasVisitadas = rels.filter(r => r.status === 'concluida').length;
    }

    // Gerar token JWT assinado incluindo a role do usuário
    const token = jwt.sign(
      { id: orientador.id, nome: orientador.nome, role: userRole },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    return success(res, {
      token,
      orientadorId: orientador.id,
      nome: orientador.nome,
      role: userRole,
      totalEscolas,
      escolasVisitadas,
    });
  } catch (err) {
    next(err);
  }
};
