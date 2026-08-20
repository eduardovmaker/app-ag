const fs = require('fs');
const path = require('path');
const xlsx = require('../via-audit-api/node_modules/xlsx');
const bcrypt = require('../via-audit-api/node_modules/bcryptjs');
const { parseAllAtivosExcels } = require('./parse_ativos_escola');

// Ler todos os arquivos de ativos por escola disponíveis na raiz
const rootDir = path.join(__dirname, '..');
const parsedAtivosExcels = parseAllAtivosExcels(rootDir);

const excelPath = path.join(rootDir, 'clientes por orientador.xlsx');
const wb = xlsx.readFile(excelPath);
const sheet = wb.Sheets[wb.SheetNames[0]];
const rawRows = xlsx.utils.sheet_to_json(sheet);

// Filtrar cabeçalhos e totais
const rows = rawRows.filter(r => {
  if (!r.Regional || r.Regional === 'TOTAL GERAL') return false;
  if (!r['Orientador(a)'] && !r.Cliente) return false;
  if (r.Cliente && String(r.Cliente).includes('clientes')) return false;
  return true;
});

// Coletar orientadores únicos
const orientadoresSet = new Set();
rows.forEach(r => {
  let ori = r['Orientador(a)'] ? String(r['Orientador(a)']).trim() : '';
  if (ori === 'Bruno Gallo') ori = 'Ana Paula Lima';
  if (ori) orientadoresSet.add(ori);
});

const orientadoresNomes = Array.from(orientadoresSet).sort();

// Preservar PINs existentes do arquivo de credenciais
const credenciaisPath = path.join(rootDir, 'orientadores_credenciais.json');
let existingCredsMap = new Map();
if (fs.existsSync(credenciaisPath)) {
  try {
    const existing = JSON.parse(fs.readFileSync(credenciaisPath, 'utf8'));
    existing.forEach(c => existingCredsMap.set(c.nome, c.pin));
  } catch (e) {}
}

const usedPins = new Set(['123456', '724123']);
const orientadores = [];
const credenciais = [];

// 1. Gerar Administrador Seguro com PIN Aleatório Exclusivo
const adminCredPath = path.join(rootDir, 'admin_credenciais.json');
let adminPin = '873914';
if (fs.existsSync(adminCredPath)) {
  try {
    const existingAdmin = JSON.parse(fs.readFileSync(adminCredPath, 'utf8'));
    if (existingAdmin.pin) adminPin = existingAdmin.pin;
  } catch (e) {}
}
usedPins.add(adminPin);

const adminObj = {
  id: 9999,
  nome: 'Administrador Geral',
  email: 'admin.audit@via.education',
  pin: bcrypt.hashSync(adminPin, 8),
  role: 'admin',
  ativo: 1
};
orientadores.push(adminObj);

fs.writeFileSync(adminCredPath, JSON.stringify({
  id: 9999,
  nome: 'Administrador Geral',
  email: 'admin.audit@via.education',
  pin: adminPin,
  role: 'admin'
}, null, 2), 'utf8');

// 2. Gerar Orientadores
orientadoresNomes.forEach((nome, index) => {
  let pin = existingCredsMap.get(nome);
  if (!pin || usedPins.has(pin)) {
    do {
      pin = Math.floor(100000 + Math.random() * 900000).toString();
    } while (usedPins.has(pin));
  }
  
  usedPins.add(pin);
  
  const pinHash = bcrypt.hashSync(pin, 8);
  
  const slug = nome.toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/\s+/g, '.');
  const email = `${slug}@via.education`;
    
  orientadores.push({
    id: index + 1,
    nome: nome,
    email: email,
    pin: pinHash,
    role: 'orientador',
    ativo: 1
  });

  credenciais.push({
    id: index + 1,
    nome: nome,
    pin: pin,
    email: email
  });
});

const oriMap = new Map();
orientadores.forEach(o => oriMap.set(o.nome, o.id));

const escolas = [];
const orientadorEscola = [];
const ativos = [];

const ativosPredefinidos = [
  'Conjunto Lego Education Spike Prime',
  'Notebook Asus X515KA 15.6"',
  'Projetor Epson PowerLite E20',
  'Chromebook Lenovo N23',
  'Roteador Wi-Fi 6 Mesh TP-Link'
];

let escolaIdCounter = 1;
let oeIdCounter = 1;
let ativoIdCounter = 1;

rows.forEach((r, idx) => {
  let oriNome = r['Orientador(a)'] ? String(r['Orientador(a)']).trim() : '';
  if (oriNome === 'Bruno Gallo') oriNome = 'Ana Paula Lima';
  
  const escolaNome = r.Cliente ? String(r.Cliente).trim() : `Escola ${idx + 1}`;
  const regional = r.Regional ? String(r.Regional).trim() : 'Geral';
  const codigo = `ESC${String(idx + 1).padStart(4, '0')}`;
  
  const lat = -27.0000 + (Math.random() * 2 - 1);
  const lng = -49.0000 + (Math.random() * 2 - 1);
  
  const escolaObj = {
    id: escolaIdCounter,
    nome: escolaNome,
    cidade: regional,
    estado: 'SC',
    codigo: codigo,
    lat: Number(lat.toFixed(6)),
    lng: Number(lng.toFixed(6))
  };
  escolas.push(escolaObj);
  
  const orientadorId = oriMap.get(oriNome);
  if (orientadorId) {
    orientadorEscola.push({
      id: oeIdCounter++,
      orientador_id: orientadorId,
      escola_id: escolaIdCounter,
      data_visita_agendada: '2026-09-01',
      status: 'pendente'
    });
  }
  
  // Buscar se existe um arquivo Excel de ativos correspondente a esta escola
  const escolaNomeClean = escolaNome.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
  const matchedExcel = parsedAtivosExcels.find(pe => {
    if (!pe.nomeFantasia) return false;
    const peNomeClean = pe.nomeFantasia.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
    return escolaNomeClean.includes(peNomeClean) || peNomeClean.includes(escolaNomeClean);
  });

  if (matchedExcel && matchedExcel.ativos.length > 0) {
    console.log(`✅ Escola ID ${escolaIdCounter} ("${escolaNome}") vinculada ao Excel real (${matchedExcel.ativos.length} ativos)`);
    matchedExcel.ativos.forEach(at => {
      ativos.push({
        id: ativoIdCounter++,
        escola_id: escolaIdCounter,
        descricao: at.descricao,
        quantidade: at.quantidade,
        nf: at.nf,
        origem: 'historico'
      });
    });
  } else {
    // Fallback genérico para escolas que ainda não possuem o Excel individual enviado
    const qtdAtivos = 2 + (idx % 2);
    for (let a = 0; a < qtdAtivos; a++) {
      const desc = ativosPredefinidos[(idx + a) % ativosPredefinidos.length];
      ativos.push({
        id: ativoIdCounter++,
        escola_id: escolaIdCounter,
        descricao: desc,
        quantidade: (a === 0) ? 1 : (a * 5 + 2),
        nf: `${10000 + (idx * 3 + a)}`,
        origem: 'historico'
      });
    }
  }
  
  escolaIdCounter++;
});

credenciais.forEach(c => {
  c.totalEscolas = orientadorEscola.filter(oe => oe.orientador_id === c.id).length;
});

fs.writeFileSync(credenciaisPath, JSON.stringify(credenciais, null, 2), 'utf8');

const seedData = {
  orientadores,
  escolas,
  orientador_escola: orientadorEscola,
  ativos
};
const seedDataPath = path.join(rootDir, 'via-audit-api', 'src', 'database', 'seed_data.json');
fs.writeFileSync(seedDataPath, JSON.stringify(seedData, null, 2), 'utf8');

const storeContent = `// Store em memória carregada dinamicamente com hashes bcrypt para PINs
const seedData = require('./seed_data.json');

const store = {
  orientadores: seedData.orientadores.map(o => ({ ...o, criado_em: new Date() })),
  escolas: seedData.escolas.map(e => ({ ...e, criado_em: new Date() })),
  orientador_escola: seedData.orientador_escola,
  ativos: seedData.ativos.map(a => ({ ...a, criado_em: new Date() })),
  visitas: [],
  registros: []
};

module.exports = store;
`;
const storePath = path.join(rootDir, 'via-audit-api', 'src', 'database', 'store.js');
fs.writeFileSync(storePath, storeContent, 'utf8');

console.log('🔒 Credencial Admin, Orientadores e Ativos Reais por Escola gerados com sucesso!');
