// Store em memória carregada dinamicamente com hashes bcrypt para PINs
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
