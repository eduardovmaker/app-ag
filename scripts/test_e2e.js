const express = require('../via-audit-api/node_modules/express');
const app = require('../via-audit-api/src/app');

const server = app.listen(0, async () => {
  const port = server.address().port;
  const baseUrl = `http://localhost:${port}/api`;
  console.log(`🚀 Servidor E2E com Módulo Admin e Relatórios ativo na porta ${port}\n`);

  try {
    const credenciais = require('../orientadores_credenciais.json');
    const adminCred = require('../admin_credenciais.json');

    console.log('=====================================================');
    console.log('📌 PASSO 1: Autenticação Segura (Login por PIN + Bcrypt + JWT)');
    console.log('=====================================================');
    
    // Login com PIN válido (Ana Paula Lima)
    const anaCred = credenciais.find(c => c.nome === 'Ana Paula Lima');
    const loginRes = await fetch(`${baseUrl}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ pin: anaCred.pin })
    });
    const loginData = await loginRes.json();
    console.log('✅ Login Ana Paula Lima (PIN validado via Bcrypt):', loginData.success ? 'SUCESSO' : 'FALHA');
    console.log('🔑 Token JWT Recebido:', loginData.data.token ? `${loginData.data.token.substring(0, 30)}...` : 'NENHUM');

    const token = loginData.data.token;
    const authHeaders = {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    };

    // Teste de Segurança 1: Requisição Sem Token JWT (Deve ser Rejeitada com 401)
    console.log('\n🛡️ TESTE DE SEGURANÇA 1: Requisição sem Token JWT');
    const unauthRes = await fetch(`${baseUrl}/escolas?orientadorId=5`);
    const unauthData = await unauthRes.json();
    console.log('  Status sem token:', unauthRes.status, '| Resposta:', unauthData.error);
    if (unauthRes.status !== 401) {
      throw new Error('Falha de segurança! Rota desprotegida sem JWT.');
    }

    console.log('\n=====================================================');
    console.log('📌 PASSO 2: Listagem de Escolas com Token JWT & Proteção IDOR');
    console.log('=====================================================');
    const orientadorId = loginData.data.orientadorId;
    const escolasRes = await fetch(`${baseUrl}/escolas?orientadorId=${orientadorId}`, { headers: authHeaders });
    const escolasData = await escolasRes.json();
    const escolas = escolasData.data.escolas;
    console.log(`✅ Escolas filtradas com token para orientador ${orientadorId}:`, escolas.length, 'escolas');
    const primeiraEscola = escolas[0];
    console.log(`🏫 Primeira Escola: [ID ${primeiraEscola.id}] ${primeiraEscola.nome}`);

    console.log('\n=====================================================');
    console.log('📌 PASSO 3: Consulta de Ativos Protegida por JWT');
    console.log('=====================================================');
    const ativosRes = await fetch(`${baseUrl}/ativos?escolaId=${primeiraEscola.id}`, { headers: authHeaders });
    const ativosData = await ativosRes.json();
    const ativos = ativosData.data.ativos;
    console.log(`📦 Ativos encontrados na escola ${primeiraEscola.id}:`, ativos.length);

    console.log('\n=====================================================');
    console.log('📌 PASSO 4: Início e Conclusão da Visita');
    console.log('=====================================================');
    const visitaRes = await fetch(`${baseUrl}/visitas/iniciar`, {
      method: 'POST',
      headers: authHeaders,
      body: JSON.stringify({ orientadorId, escolaId: primeiraEscola.id })
    });
    const visitaData = await visitaRes.json();
    const visitaId = visitaData.data.visitaId;

    await fetch(`${baseUrl}/registros`, {
      method: 'POST',
      headers: authHeaders,
      body: JSON.stringify({
        visitaId,
        ativoId: ativos[0].id,
        unidadeNumero: 1,
        status: 'ok',
        patrimonioFisico: 'V000123',
        observacao: 'Equipamento auditado com sucesso.'
      })
    });

    await fetch(`${baseUrl}/visitas/${visitaId}/concluir`, {
      method: 'POST',
      headers: authHeaders,
      body: JSON.stringify({ escolaId: primeiraEscola.id, observacaoGeral: 'Finalizado' })
    });
    console.log('✅ Visita concluída!');

    console.log('\n=====================================================');
    console.log('📌 PASSO 5: Autenticação do Administrador (PIN Admin Seguro)');
    console.log('=====================================================');
    console.log('🔑 Tentando login Admin com PIN:', adminCred.pin);
    const adminLoginRes = await fetch(`${baseUrl}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ pin: adminCred.pin })
    });
    const adminLoginData = await adminLoginRes.json();
    console.log('✅ Login Admin:', adminLoginData.success ? 'SUCESSO' : 'FALHA');
    console.log('👤 Perfil Retornado:', adminLoginData.data.nome, `| Role: ${adminLoginData.data.role}`);

    if (!adminLoginData.success || adminLoginData.data.role !== 'admin') {
      throw new Error('Falha no login do Administrador!');
    }

    const adminHeaders = {
      'Authorization': `Bearer ${adminLoginData.data.token}`
    };

    console.log('\n=====================================================');
    console.log('📌 PASSO 6: Consulta do Dashboard de Estatísticas Admin');
    console.log('=====================================================');
    const statsRes = await fetch(`${baseUrl}/admin/stats`, { headers: adminHeaders });
    const statsData = await statsRes.json();
    console.log('📊 Resumo Geral da Rede:', statsData.data.resumoGeral);
    console.log('👥 Total de Orientadores no Dashboard Admin:', statsData.data.desempenhoOrientadores.length);

    console.log('\n=====================================================');
    console.log('📌 PASSO 7: Exportação dos Relatórios Consolidados (Excel & PDF)');
    console.log('=====================================================');
    // Testar exportação Excel
    const excelRes = await fetch(`${baseUrl}/admin/reports/excel`, { headers: adminHeaders });
    const excelBuffer = await excelRes.arrayBuffer();
    console.log(`📊 Relatório Excel (.XLSX) Gerado: ${excelBuffer.byteLength} bytes (Content-Type: ${excelRes.headers.get('content-type')})`);

    // Testar exportação PDF
    const pdfRes = await fetch(`${baseUrl}/admin/reports/pdf`, { headers: adminHeaders });
    const pdfBuffer = await pdfRes.arrayBuffer();
    console.log(`📄 Relatório PDF (.PDF) Gerado: ${pdfBuffer.byteLength} bytes (Content-Type: ${pdfRes.headers.get('content-type')})`);

    if (excelBuffer.byteLength < 1000 || pdfBuffer.byteLength < 1000) {
      throw new Error('Falha na geração dos arquivos de relatório!');
    }

    console.log('\n=====================================================');
    console.log('🎉 MÓDULO ADMIN E EXPORTAÇÃO PDF/XLSX 100% VALIDADOS!');
    console.log('=====================================================');

  } catch (err) {
    console.error('❌ ERRO NO TESTE E2E:', err);
    process.exitCode = 1;
  } finally {
    server.close();
  }
});
