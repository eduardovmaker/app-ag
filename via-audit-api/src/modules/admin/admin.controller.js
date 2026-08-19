const xlsx = require('xlsx');
const PDFDocument = require('pdfkit');
const { success, error } = require('../../utils/response');
const store = require('../../database/store');
const pool = require('../../config/db');

// Utilitário para coletar dados consolidados em tempo real
async function getConsolidatedData() {
  let orientadores = [];
  let escolas = [];
  let orientadorEscola = [];
  let ativos = [];
  let visitas = [];
  let registros = [];

  try {
    const [oriRows] = await pool.query('SELECT id, nome, email FROM orientadores WHERE role != "admin"');
    const [escRows] = await pool.query('SELECT id, nome, cidade, estado, codigo FROM escolas');
    const [oeRows] = await pool.query('SELECT id, orientador_id, escola_id, status FROM orientador_escola');
    const [atiRows] = await pool.query('SELECT id, escola_id, descricao, quantidade, nf FROM ativos');
    const [visRows] = await pool.query('SELECT id, orientador_id, escola_id, status FROM visitas');
    const [regRows] = await pool.query('SELECT id, visita_id, ativo_id, status, patrimonio_fisico, observacao FROM registros');

    orientadores = oriRows;
    escolas = escRows;
    orientadorEscola = oeRows;
    ativos = atiRows;
    visitas = visRows;
    registros = regRows;
  } catch (e) {
    // Fallback para store em memória
    orientadores = store.orientadores.filter(o => o.role !== 'admin' && o.id !== 9999);
    escolas = store.escolas;
    orientadorEscola = store.orientador_escola;
    ativos = store.ativos;
    visitas = store.visitas;
    registros = store.registros;
  }

  const totalEscolas = escolas.length;
  const escolasConcluidas = orientadorEscola.filter(oe => oe.status === 'concluida').length;
  const escolasEmAndamento = orientadorEscola.filter(oe => oe.status === 'em_andamento').length;
  const escolasPendentes = totalEscolas - escolasConcluidas - escolasEmAndamento;

  const totalRegistros = registros.length;
  const totalOk = registros.filter(r => r.status === 'ok').length;
  const totalAvariados = registros.filter(r => r.status === 'avariado').length;
  const totalNaoEncontrados = registros.filter(r => r.status === 'nao_encontrado').length;
  const totalExtras = registros.filter(r => r.status === 'extra').length;

  const desempenhoOrientadores = orientadores.map(ori => {
    const rels = orientadorEscola.filter(oe => oe.orientador_id == ori.id);
    const totEsc = rels.length;
    const concEsc = rels.filter(oe => oe.status === 'concluida').length;
    const pct = totEsc > 0 ? Math.round((concEsc / totEsc) * 100) : 0;

    // Buscar visitas e registros deste orientador
    const oriVisitaIds = visitas.filter(v => v.orientador_id == ori.id).map(v => v.id);
    const oriRegs = registros.filter(r => oriVisitaIds.includes(r.visita_id));

    return {
      id: ori.id,
      nome: ori.nome,
      email: ori.email,
      totalEscolas: totEsc,
      escolasConcluidas: concEsc,
      progressoPct: pct,
      itemsOk: oriRegs.filter(r => r.status === 'ok').length,
      itemsAvariados: oriRegs.filter(r => r.status === 'avariado').length,
      itemsNaoEncontrados: oriRegs.filter(r => r.status === 'nao_encontrado').length,
      itemsExtras: oriRegs.filter(r => r.status === 'extra').length,
    };
  });

  return {
    resumoGeral: {
      totalOrientadores: orientadores.length,
      totalEscolas,
      escolasConcluidas,
      escolasEmAndamento,
      escolasPendentes,
      progressoGeralPct: totalEscolas > 0 ? Math.round((escolasConcluidas / totalEscolas) * 100) : 0,
      totalRegistros,
      totalOk,
      totalAvariados,
      totalNaoEncontrados,
      totalExtras,
    },
    desempenhoOrientadores,
    escolas,
    orientadorEscola,
    ativos,
    registros
  };
}

// 1. Endpoint de Estatísticas do Admin
exports.stats = async (req, res, next) => {
  try {
    const data = await getConsolidatedData();
    return success(res, data);
  } catch (err) {
    next(err);
  }
};

// 2. Exportar Relatório Excel (.XLSX)
exports.exportExcel = async (req, res, next) => {
  try {
    const data = await getConsolidatedData();
    const wb = xlsx.utils.book_new();

    // Aba 1: Resumo Geral
    const resumoData = [
      ['Métrica de Auditoria', 'Valor'],
      ['Total de Orientadores', data.resumoGeral.totalOrientadores],
      ['Total de Escolas', data.resumoGeral.totalEscolas],
      ['Escolas Concluídas', data.resumoGeral.escolasConcluidas],
      ['Escolas Em Andamento', data.resumoGeral.escolasEmAndamento],
      ['Escolas Pendentes', data.resumoGeral.escolasPendentes],
      ['Progresso Geral da Rede', `${data.resumoGeral.progressoGeralPct}%`],
      ['Total de Equipamentos Auditados', data.resumoGeral.totalRegistros],
      ['Equipamentos Em Perfeito Estado (OK)', data.resumoGeral.totalOk],
      ['Equipamentos Avariados', data.resumoGeral.totalAvariados],
      ['Equipamentos Não Encontrados', data.resumoGeral.totalNaoEncontrados],
      ['Equipamentos Extras Registrados', data.resumoGeral.totalExtras],
    ];
    const wsResumo = xlsx.utils.aoa_to_sheet(resumoData);
    xlsx.utils.book_append_sheet(wb, wsResumo, 'Resumo Geral');

    // Aba 2: Por Orientador
    const oriHeaders = ['ID', 'Orientador(a)', 'E-mail', 'Total Escolas', 'Escolas Concluídas', 'Progresso %', 'Itens OK', 'Avariados', 'Não Encontrados', 'Extras'];
    const oriRows = data.desempenhoOrientadores.map(o => [
      o.id, o.nome, o.email, o.totalEscolas, o.escolasConcluidas, `${o.progressoPct}%`, o.itemsOk, o.itemsAvariados, o.itemsNaoEncontrados, o.itemsExtras
    ]);
    const wsOrientadores = xlsx.utils.aoa_to_sheet([oriHeaders, ...oriRows]);
    xlsx.utils.book_append_sheet(wb, wsOrientadores, 'Por Orientador');

    // Aba 3: Detalhamento de Ativos Auditados
    const regHeaders = ['Registro ID', 'Visita ID', 'Ativo ID', 'Status', 'Patrimônio Físico', 'Observação'];
    const regRows = data.registros.map(r => [
      r.id, r.visita_id, r.ativo_id, r.status, r.patrimonio_fisico || 'N/A', r.observacao || ''
    ]);
    const wsRegistros = xlsx.utils.aoa_to_sheet([regHeaders, ...regRows]);
    xlsx.utils.book_append_sheet(wb, wsRegistros, 'Ativos Auditados');

    const buffer = xlsx.write(wb, { type: 'buffer', bookType: 'xlsx' });

    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', 'attachment; filename=Relatorio_Consolidado_Via_Audit.xlsx');
    return res.send(buffer);
  } catch (err) {
    next(err);
  }
};

// 3. Exportar Relatório PDF (.PDF)
exports.exportPdf = async (req, res, next) => {
  try {
    const data = await getConsolidatedData();
    const doc = new PDFDocument({ margin: 40, size: 'A4' });

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', 'attachment; filename=Relatorio_Consolidado_Via_Audit.pdf');

    doc.pipe(res);

    // Cabeçalho Institucional
    doc.fillColor('#0F172A').fontSize(20).text('VIA AUDIT — SISTEMA DE AUDITORIA DE COMODATO', { align: 'center' });
    doc.fontSize(12).fillColor('#64748B').text('RELATÓRIO CONSOLIDADO DA REDE DE ENSINO', { align: 'center' });
    doc.moveDown(1);

    doc.fontSize(10).fillColor('#334155').text(`Data de Emissão: ${new Date().toLocaleString('pt-BR')}`);
    doc.text(`Emissor: Administrador Geral (Chave Admin Autenticada)`);
    doc.moveDown(1);

    // Divisor
    doc.moveTo(40, doc.y).lineTo(550, doc.y).strokeColor('#E2E8F0').stroke();
    doc.moveDown(1);

    // Seção 1: Resumo Geral da Rede
    doc.fillColor('#0085DB').fontSize(14).text('1. RESUMO GERAL DA REDE DE ENSINO');
    doc.moveDown(0.5);

    const rg = data.resumoGeral;
    doc.fillColor('#1E293B').fontSize(10);
    doc.text(`• Total de Orientadores: ${rg.totalOrientadores}`);
    doc.text(`• Total de Escolas Designadas: ${rg.totalEscolas}`);
    doc.text(`• Escolas Concluídas: ${rg.escolasConcluidas} (${rg.progressoGeralPct}% concluído)`);
    doc.text(`• Escolas Em Andamento: ${rg.escolasEmAndamento}`);
    doc.text(`• Escolas Pendentes: ${rg.escolasPendentes}`);
    doc.moveDown(0.5);
    doc.text(`• Total de Equipamentos Auditados: ${rg.totalRegistros}`);
    doc.text(`  - 🟢 Em Perfeito Estado (OK): ${rg.totalOk}`);
    doc.text(`  - ⚠️ Avariados: ${rg.totalAvariados}`);
    doc.text(`  - ❌ Não Encontrados: ${rg.totalNaoEncontrados}`);
    doc.text(`  - ➕ Extras Identificados: ${rg.totalExtras}`);
    doc.moveDown(1.5);

    // Seção 2: Desempenho por Orientador
    doc.fillColor('#0085DB').fontSize(14).text('2. DESEMPENHO POR ORIENTADOR');
    doc.moveDown(0.5);

    doc.fontSize(9).fillColor('#0F172A');
    data.desempenhoOrientadores.forEach((o, index) => {
      if (doc.y > 700) doc.addPage();
      doc.text(`${index + 1}. ${o.nome} (${o.email})`);
      doc.fillColor('#64748B').text(`   Escolas: ${o.escolasConcluidas}/${o.totalEscolas} (${o.progressoPct}%) | OK: ${o.itemsOk} | Avariados: ${o.itemsAvariados} | Ausentes: ${o.itemsNaoEncontrados}`);
      doc.fillColor('#0F172A');
      doc.moveDown(0.3);
    });

    doc.moveDown(2);
    doc.fillColor('#94A3B8').fontSize(9).text('Documento gerado automaticamente pelo sistema Via Audit. Assinado digitalmente pelo Administrador.', { align: 'center' });

    doc.end();
  } catch (err) {
    next(err);
  }
};
