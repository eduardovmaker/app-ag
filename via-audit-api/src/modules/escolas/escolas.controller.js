const { success, error } = require('../../utils/response');
const pool = require('../../config/db');
const store = require('../../database/store');

exports.listar = async (req, res, next) => {
  try {
    const orientadorId = parseInt(req.query.orientadorId, 10);
    if (!orientadorId) {
      return error(res, 'Parametro orientadorId e obrigatorio', 400);
    }

    let orientadorNome = "Daniela Moreira";
    let escolasList = [];

    try {
      const [oriRows] = await pool.query('SELECT nome FROM orientadores WHERE id = ?', [orientadorId]);
      if (oriRows && oriRows.length > 0) orientadorNome = oriRows[0].nome;

      const [rows] = await pool.query(
        `SELECT e.id, e.nome, e.cidade, e.estado, e.lat, e.lng, oe.data_visita_agendada as dataVisitaAgendada, oe.status,
                (SELECT COUNT(*) FROM ativos a WHERE a.escola_id = e.id) as totalAtivos,
                (SELECT COUNT(DISTINCT r.ativo_id) FROM registros r JOIN visitas v ON r.visita_id = v.id WHERE v.escola_id = e.id) as ativosConferidos
         FROM escolas e
         JOIN orientador_escola oe ON e.id = oe.escola_id
         WHERE oe.orientador_id = ?
         ORDER BY 
           CASE oe.status 
             WHEN 'pendente' THEN 1 
             WHEN 'em_andamento' THEN 2 
             WHEN 'concluida' THEN 3 
             ELSE 4 
           END, oe.data_visita_agendada ASC`,
        [orientadorId]
      );
      escolasList = rows;
    } catch (e) {
      // Fallback em memória
      const ori = store.orientadores.find(o => o.id === orientadorId);
      if (ori) orientadorNome = ori.nome;

      const rels = store.orientador_escola.filter(r => r.orientador_id === orientadorId);
      escolasList = rels.map(rel => {
        const esc = store.escolas.find(e => e.id === rel.escola_id) || {};
        const totalAtivos = store.ativos.filter(a => a.escola_id === esc.id).reduce((acc, a) => acc + a.quantidade, 0);
        return {
          id: esc.id,
          nome: esc.nome,
          cidade: esc.cidade,
          estado: esc.estado,
          lat: esc.lat,
          lng: esc.lng,
          dataVisitaAgendada: rel.data_visita_agendada,
          status: rel.status,
          totalAtivos: totalAtivos || 9,
          ativosConferidos: rel.status === 'concluida' ? totalAtivos : (rel.status === 'em_andamento' ? 3 : 0)
        };
      });
    }

    const total = escolasList.length;
    const visitadas = escolasList.filter(e => e.status === 'concluida').length;

    return success(res, {
      orientador: { id: orientadorId, nome: orientadorNome },
      resumo: { total, visitadas, semanaAtual: 3, totalSemanas: 8 },
      escolas: escolasList,
    });
  } catch (err) {
    next(err);
  }
};
