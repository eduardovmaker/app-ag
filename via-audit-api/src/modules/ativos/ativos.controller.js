const { success, error } = require('../../utils/response');
const pool = require('../../config/db');
const store = require('../../database/store');

exports.listar = async (req, res, next) => {
  try {
    const escolaId = parseInt(req.query.escolaId, 10);
    const orientadorId = req.user ? req.user.id : parseInt(req.query.orientadorId, 10);

    if (!escolaId) {
      return error(res, 'Parametro escolaId e obrigatorio', 400);
    }

    let escola = null;
    let ativosList = [];

    try {
      const [escRows] = await pool.query('SELECT id, nome, codigo FROM escolas WHERE id = ?', [escolaId]);
      if (escRows && escRows.length > 0) escola = escRows[0];

      const [rows] = await pool.query(
        'SELECT id, descricao, quantidade, nf, origem FROM ativos WHERE escola_id = ?',
        [escolaId]
      );
      ativosList = rows;
    } catch (e) {
      // Fallback em memória
      const esc = store.escolas.find(e => e.id === escolaId);
      if (esc) escola = { id: esc.id, nome: esc.nome, codigo: esc.codigo };
      ativosList = store.ativos.filter(a => a.escola_id === escolaId);
    }

    if (!escola) {
      escola = { id: escolaId, nome: "Colégio Álamo Vinhedo", codigo: "023448" };
    }

    // Mapear statusChecklist e contagens detalhadas por tipo
    let totalItens = 0;
    let conferidos = 0;

    const ativosComStatus = ativosList.map(a => {
      totalItens += a.quantidade;
      let regCount = 0;
      let statusChecklist = 'pendente';

      // Buscar registros gravados para este ativo
      const regs = store.registros.filter(r => r.ativo_id == a.id);
      regCount = regs.length;

      const qtdOk = regs.filter(r => r.status === 'ok').length;
      const qtdAvariado = regs.filter(r => r.status === 'avariado').length;
      const qtdNaoEncontrado = regs.filter(r => r.status === 'nao_encontrado').length;
      const qtdExtra = regs.filter(r => r.status === 'extra').length;

      if (regCount >= a.quantidade) {
        const temDivergencia = regs.some(r => r.status !== 'ok');
        statusChecklist = temDivergencia ? 'divergente' : 'conferido';
        conferidos += a.quantidade;
      } else if (regCount > 0) {
        statusChecklist = 'em_andamento';
        conferidos += regCount;
      }

      return {
        id: a.id,
        escolaId: a.escola_id || escolaId,
        descricao: a.descricao,
        quantidade: a.quantidade,
        nf: a.nf,
        origem: a.origem,
        statusChecklist,
        unidadesRegistradas: regCount,
        qtdOk,
        qtdAvariado,
        qtdNaoEncontrado,
        qtdExtra
      };
    });

    return success(res, {
      escola,
      resumo: { totalItens, conferidos },
      ativos: ativosComStatus,
    });
  } catch (err) {
    next(err);
  }
};
