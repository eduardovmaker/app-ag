const fs = require('fs');
const path = require('path');
const xlsx = require('../via-audit-api/node_modules/xlsx');

function isTargetAssetCategory(descricao, categoria) {
  const desc = (descricao || '').toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').trim();

  // Excluir expressamente itens de papelaria, marketing impresso e utilitários gerais
  const ignoreTerms = [
    'encarte', 'cartaz', 'banner', 'paper tools', 'placa de parceria',
    'separador de pecas', 'filtro de linha', 'extensor usb', 'microfone',
    'soft box', 'webcam'
  ];
  if (ignoreTerms.some(term => desc.includes(term))) {
    return false;
  }

  // 1. Tablet & iPad (e acessórios diretos como capas e carregadores)
  if (desc.includes('tablet') || desc.includes('ipad')) return true;

  // 2. Notebooks & Chromebooks
  if (desc.includes('notebook') || desc.includes('chromebook')) return true;

  // 3. Robô programável (robô e seus tapetes específicos)
  if (desc.includes('robo')) return true;

  // 4. Astrocar
  if (desc.includes('astrocar')) return true;

  // 5. Tapete de torneio & Saia de mesa
  if (desc.includes('tapete') || desc.includes('saia de mesa')) return true;

  // 6. Kits Lego e Kits Lego com sufixo -SN (Spike, EV3, WeDo, Duplo, Steam, etc.)
  const legoKeywords = [
    'spike', 'ev3', 'wedo', 'lego', 'duplo', 'steam', 'conjunto',
    'bloco inteligente', 'smarthub', 'motor medio', 'hub pequeno',
    'bateria recarregavel', 'maquinas tecnologicas', 'experimentos com tubo'
  ];

  if (legoKeywords.some(kw => desc.includes(kw))) {
    return true;
  }

  return false;
}

function parseAtivosExcelFile(filePath) {
  const wb = xlsx.readFile(filePath);
  const sheet = wb.Sheets[wb.SheetNames[0]];
  const rawRows = xlsx.utils.sheet_to_json(sheet, { header: 1 });

  let nomeFantasia = '';
  let razaoSocial = '';
  let codigoLoja = '';

  // Extrair metadados das primeiras linhas
  for (let i = 0; i < Math.min(10, rawRows.length); i++) {
    const row = rawRows[i];
    if (!row || row.length === 0) continue;
    const label = String(row[0] || '').trim().toLowerCase();
    if (label === 'nome fantasia') {
      nomeFantasia = String(row[1] || '').trim();
    } else if (label === 'razão social') {
      razaoSocial = String(row[1] || '').trim();
    } else if (label.includes('código') && label.includes('loja')) {
      const val = String(row[1] || '').trim();
      codigoLoja = val.split('·')[0].trim();
    }
  }

  // Localizar linha de cabeçalho das colunas (Código, Descrição, Categoria, Saldo, NF, Emissão)
  let headerIndex = -1;
  for (let i = 0; i < rawRows.length; i++) {
    const row = rawRows[i];
    if (row && row.length >= 4) {
      const col0 = String(row[0] || '').trim().toLowerCase();
      const col1 = String(row[1] || '').trim().toLowerCase();
      if (col0.includes('código') || col0.includes('codigo')) {
        if (col1.includes('descrição') || col1.includes('descricao')) {
          headerIndex = i;
          break;
        }
      }
    }
  }

  const rawAtivos = [];
  if (headerIndex !== -1) {
    for (let i = headerIndex + 1; i < rawRows.length; i++) {
      const row = rawRows[i];
      if (!row || row.length === 0) continue;
      const codigo = String(row[0] || '').trim();
      if (!codigo || codigo.toUpperCase() === 'TOTAL') continue;

      const descricao = String(row[1] || '').trim();
      if (!descricao) continue;

      const categoria = String(row[2] || '').trim();
      const saldo = parseInt(row[3], 10) || 1;
      const nf = row[4] ? String(row[4]).trim() : 'S/N';
      const emissao = row[5] ? String(row[5]).trim() : '';

      rawAtivos.push({
        codigoItem: codigo,
        descricao,
        categoria,
        quantidade: saldo,
        nf,
        emissao,
        is_auditavel: 1
      });
    }
  }

  return {
    nomeFantasia,
    razaoSocial,
    codigoLoja,
    ativos: rawAtivos
  };
}

function parseAllAtivosExcels(targetDir) {
  const filePaths = [];

  const scanDir = (dir) => {
    if (!fs.existsSync(dir)) return;
    const files = fs.readdirSync(dir);
    files.forEach(f => {
      if (f.toLowerCase().startsWith('ativos_') && f.toLowerCase().endsWith('.xlsx')) {
        filePaths.push(path.join(dir, f));
      }
    });
  };

  scanDir(targetDir);
  scanDir(path.join(targetDir, 'excel'));

  const escolaMap = new Map();
  for (const fullPath of filePaths) {
    const f = path.basename(fullPath);
    try {
      const result = parseAtivosExcelFile(fullPath);
      const key = (result.codigoLoja || result.nomeFantasia || f).toLowerCase();

      if (!escolaMap.has(key)) {
        escolaMap.set(key, {
          nomeFantasia: result.nomeFantasia,
          razaoSocial: result.razaoSocial,
          codigoLoja: result.codigoLoja,
          ativosMap: new Map()
        });
      }

      const target = escolaMap.get(key);
      result.ativos.forEach(at => {
        const atKey = at.descricao.toLowerCase().trim();
        if (target.ativosMap.has(atKey)) {
          const existing = target.ativosMap.get(atKey);
          existing.quantidade += at.quantidade;
          if (at.nf && at.nf !== 'S/N' && !existing.nfs.includes(at.nf)) {
            existing.nfs.push(at.nf);
          }
        } else {
          target.ativosMap.set(atKey, {
            ...at,
            nfs: (at.nf && at.nf !== 'S/N') ? [at.nf] : ['S/N']
          });
        }
      });

      console.log(`📦 Processado arquivo de ativos: ${f} -> Escola: "${result.nomeFantasia}" (Loja: ${result.codigoLoja}) | ${result.ativos.length} ativos lidos`);
    } catch (e) {
      console.error(`Erro ao processar ${f}:`, e);
    }
  }

  const parsedList = [];
  escolaMap.forEach((v) => {
    const listAtivos = Array.from(v.ativosMap.values()).map(item => {
      return {
        codigoItem: item.codigoItem,
        descricao: item.descricao,
        categoria: item.categoria,
        quantidade: item.quantidade,
        nf: item.nfs.join(', '),
        emissao: item.emissao,
        is_auditavel: item.is_auditavel ?? 1
      };
    });

    parsedList.push({
      nomeFantasia: v.nomeFantasia,
      razaoSocial: v.razaoSocial,
      codigoLoja: v.codigoLoja,
      ativos: listAtivos
    });
  });

  return parsedList;
}

module.exports = {
  parseAtivosExcelFile,
  parseAllAtivosExcels
};
