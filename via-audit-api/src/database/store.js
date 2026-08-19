// Store em memória com dados iniciais conforme especificação dos Prompts
const store = {
  orientadores: [
    { id: 7, nome: "Daniela Moreira", email: "daniela@viaeducation.com.br", pin: "724123", ativo: 1, criado_em: new Date() }
  ],
  escolas: [
    { id: 1, nome: "Colégio Álamo Vinhedo", cidade: "Vinhedo", estado: "SP", codigo: "023448", lat: -23.03, lng: -46.97, criado_em: new Date() },
    { id: 2, nome: "E.E. Maria José da Silva", cidade: "São Paulo", estado: "SP", codigo: "018922", lat: -23.5505, lng: -46.6333, criado_em: new Date() },
    { id: 3, nome: "E.M. Prof. Antônio Carlos", cidade: "Guarulhos", estado: "SP", codigo: "099120", lat: -23.4542, lng: -46.5337, criado_em: new Date() }
  ],
  orientador_escola: [
    { id: 1, orientador_id: 7, escola_id: 1, data_visita_agendada: "2026-06-12", status: "pendente" },
    { id: 2, orientador_id: 7, escola_id: 2, data_visita_agendada: "2026-06-11", status: "em_andamento" },
    { id: 3, orientador_id: 7, escola_id: 3, data_visita_agendada: "2026-06-10", status: "concluida" }
  ],
  ativos: [
    { id: 10, escola_id: 1, descricao: "Conjunto Spike Prime", quantidade: 1, nf: "17373", origem: "historico", criado_em: new Date() },
    { id: 11, escola_id: 1, descricao: "Notebook Asus X515KA", quantidade: 10, nf: "17233", origem: "historico", criado_em: new Date() },
    { id: 12, escola_id: 1, descricao: "Projetor Epson PowerLite", quantidade: 2, nf: "18992", origem: "historico", criado_em: new Date() },
    { id: 13, escola_id: 2, descricao: "Chromebook Lenovo N23", quantidade: 10, nf: "48291", origem: "historico", criado_em: new Date() },
    { id: 14, escola_id: 2, descricao: "Roteador Cisco Meraki", quantidade: 1, nf: "60119", origem: "historico", criado_em: new Date() }
  ],
  visitas: [
    { id: 42, orientador_id: 7, escola_id: 1, status: "em_andamento", iniciada_em: new Date(), concluida_em: null, assinatura_url: null, observacao_geral: null }
  ],
  registros: [
    { id: 101, visita_id: 42, ativo_id: 10, unidade_numero: 1, status: "ok", patrimonio_fisico: "V000010", foto_url: "/uploads/fotos/demo1.jpg", lat: -23.03, lng: -46.97, observacao: "", sincronizado: 1, criado_em: new Date() }
  ]
};

module.exports = store;
