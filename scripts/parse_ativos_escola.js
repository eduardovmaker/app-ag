const fs = require('fs');
const path = require('path');
const xlsx = require('../via-audit-api/node_modules/xlsx');

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
      if (col0 === 'código' && col1 === 'descrição') {
        headerIndex = i;
        break;
      }
    }
  }

  const ativos = [];
  if (headerIndex !== -1) {
    for (let i = headerIndex + 1; i < rawRows.length; i++) {
      const row = rawRows[i];
      if (!row || row.length === 0) continue;
      const codigo = String(row[0] || '').trim();
      if (!codigo || codigo.toUpperCase() === 'TOTAL') continue;

      const descricao = String(row[1] || '').trim();
      const categoria = String(row[2] || '').trim();
      const saldo = parseInt(row[3], 10) || 1;
      const nf = row[4] ? String(row[4]).trim() : 'S/N';
      const emissao = row[5] ? String(row[5]).trim() : '';

      if (descricao) {
        ativos.push({
          codigoItem: codigo,
          descricao,
          categoria,
          quantidade: saldo,
          nf,
          emissao
        });
      }
    }
  }

  return {
    nomeFantasia,
    razaoSocial,
    codigoLoja,
    ativos
  };
}

function parseAllAtivosExcels(rootDir) {
  const files = fs.readdirSync(rootDir);
  const ativosFiles = files.filter(f => f.toLowerCase().startsWith('ativos_') && f.toLowerCase().endsWith('.xlsx'));

  const parsedList = [];
  for (const f of ativosFiles) {
    const fullPath = path.join(rootDir, f);
    try {
      const result = parseAtivosExcelFile(fullPath);
      parsedList.push(result);
      console.log(`📦 Processado arquivo de ativos: ${f} -> Escola: "${result.nomeFantasia}" (Loja: ${result.codigoLoja}) | ${result.ativos.length} itens`);
    } catch (e) {
      console.error(`Erro ao processar ${f}:`, e);
    }
  }
  return parsedList;
}

module.exports = {
  parseAtivosExcelFile,
  parseAllAtivosExcels
};
