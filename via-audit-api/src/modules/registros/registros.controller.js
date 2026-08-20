const { success, error } = require('../../utils/response');
const pool = require('../../config/db');
const store = require('../../database/store');
const { compressImageFile } = require('../../utils/imageCompressor');

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

    const files = req.files || {};
    const fotoFile1 = files['foto'] ? files['foto'][0] : null;
    const fotoFile2 = files['foto2'] ? files['foto2'][0] : null;
    const fotoFile3 = files['foto3'] ? files['foto3'][0] : null;

    if (fotoFile1) await compressImageFile(fotoFile1.path);
    if (fotoFile2) await compressImageFile(fotoFile2.path);
    if (fotoFile3) await compressImageFile(fotoFile3.path);

    const fotoUrl1 = fotoFile1 ? `/uploads/fotos/${fotoFile1.filename}` : null;
    const fotoUrl2 = fotoFile2 ? `/uploads/fotos/${fotoFile2.filename}` : null;
    const fotoUrl3 = fotoFile3 ? `/uploads/fotos/${fotoFile3.filename}` : null;

    let registroId = Date.now();

    try {
      const [result] = await pool.query(
        `INSERT INTO registros 
          (visita_id, ativo_id, unidade_numero, status, patrimonio_fisico, foto_url, foto_url2, foto_url3, lat, lng, observacao, sincronizado) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)`,
        [visitaId, ativoId, unidadeNumero || 1, status, patrimonioFisico || '', fotoUrl1, fotoUrl2, fotoUrl3, lat || null, lng || null, observacao || '']
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
        foto_url: fotoUrl1,
        foto_url2: fotoUrl2,
        foto_url3: fotoUrl3,
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
