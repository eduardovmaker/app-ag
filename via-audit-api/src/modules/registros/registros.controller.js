const { success, error } = require('../../utils/response');
const pool = require('../../config/db');
const store = require('../../database/store');

exports.salvar = async (req, res, next) => {
  try {
    const {
      visitaId,
      ativoId,
      unidadeNumero,
      status,
      patrimonioFisico,
      lat,
      lng,
      observacao,
    } = req.body;

    const fotoFile = req.file;
    const fotoUrl = fotoFile ? `/uploads/fotos/${fotoFile.filename}` : '/uploads/fotos/placeholder.jpg';

    let registroId = Date.now();

    try {
      const [result] = await pool.query(
        `INSERT INTO registros 
          (visita_id, ativo_id, unidade_numero, status, patrimonio_fisico, foto_url, lat, lng, observacao, sincronizado) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1)`,
        [visitaId, ativoId, unidadeNumero || 1, status, patrimonioFisico || '', fotoUrl, lat || null, lng || null, observacao || '']
      );
      registroId = result.insertId;
    } catch (e) {
      // Fallback em memória
      store.registros.push({
        id: registroId,
        visita_id: parseInt(visitaId),
        ativo_id: parseInt(ativoId),
        unidade_numero: parseInt(unidadeNumero || 1),
        status,
        patrimonio_fisico: patrimonioFisico || '',
        foto_url: fotoUrl,
        lat: parseFloat(lat) || null,
        lng: parseFloat(lng) || null,
        observacao: observacao || '',
        sincronizado: 1,
        criado_em: new Date()
      });
    }

    return success(res, { registroId });
  } catch (err) {
    next(err);
  }
};

exports.validarPatrimonio = async (req, res, next) => {
  try {
    const { codigo, ativoId } = req.query;

    if (!codigo) {
      return error(res, 'Parametro codigo e obrigatorio', 400);
    }

    // Regra de validação regex de patrimônio Via Education: V[0-9]{6} ou PAT-...
    const eValido = /^V\d{6}$/i.test(codigo) || /^PAT-/i.test(codigo);

    if (eValido) {
      let descricao = "Equipamento auditado";
      const ativo = store.ativos.find(a => a.id == ativoId);
      if (ativo) descricao = ativo.descricao;

      return success(res, {
        valido: true,
        descricao,
      });
    } else {
      return success(res, {
        valido: false,
        motivo: "Patrimônio não corresponde ao padrão esperado (ex: V000026)",
      });
    }
  } catch (err) {
    next(err);
  }
};
