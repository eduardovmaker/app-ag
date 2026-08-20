const { success, error } = require('../../utils/response');
const store = require('../../database/store');
const fs = require('fs');
const path = require('path');

exports.uploadBatch = async (req, res, next) => {
  try {
    const { registros } = req.body;

    if (!registros || !Array.isArray(registros)) {
      return error(res, 'Array de registros é obrigatório', 400);
    }

    let salvos = 0;
    const erros = [];

    for (const reg of registros) {
      try {
        const saveBase64 = (b64String, prefix) => {
          if (!b64String) return null;
          if (typeof b64String !== 'string' || (!b64String.startsWith('data:image/') && b64String.length > 5000000)) {
            throw new Error('Formato ou tamanho inválido de imagem Base64');
          }
          const filename = `${prefix}-${Date.now()}-${Math.round(Math.random() * 1000)}.jpg`;
          const uploadDir = path.join(__dirname, '../../../uploads/fotos');
          if (!fs.existsSync(uploadDir)) {
            fs.mkdirSync(uploadDir, { recursive: true });
          }
          const base64Data = b64String.replace(/^data:image\/\w+;base64,/, '');
          fs.writeFileSync(path.join(uploadDir, filename), base64Data, 'base64');
          return `/uploads/fotos/${filename}`;
        };

        const fotoUrl1 = saveBase64(reg.fotoBase64, 'sync1');
        const fotoUrl2 = saveBase64(reg.fotoBase64_2, 'sync2');
        const fotoUrl3 = saveBase64(reg.fotoBase64_3, 'sync3');

        store.registros.push({
          id: Date.now() + salvos,
          visita_id: parseInt(reg.visitaId),
          ativo_id: parseInt(reg.ativoId),
          unidade_numero: parseInt(reg.unidadeNumero || 1),
          status: reg.status,
          patrimonio_fisico: reg.patrimonioFisico || '',
          foto_url: fotoUrl1,
          foto_url2: fotoUrl2,
          foto_url3: fotoUrl3,
          lat: parseFloat(reg.lat) || null,
          lng: parseFloat(reg.lng) || null,
          observacao: reg.observacao || '',
          sincronizado: 1,
          criado_em: reg.criadoEm ? new Date(reg.criadoEm) : new Date()
        });

        salvos++;
      } catch (errReg) {
        erros.push({ localId: reg.localId, motivo: errReg.message });
      }
    }

    return success(res, { salvos, erros });
  } catch (err) {
    next(err);
  }
};
