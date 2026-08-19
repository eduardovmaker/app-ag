const express = require('express');
const cors = require('cors');
const path = require('path');
const errorHandler = require('./middlewares/errorHandler');

const orientadoresRoutes = require('./modules/orientadores/orientadores.routes');
const escolasRoutes = require('./modules/escolas/escolas.routes');
const ativosRoutes = require('./modules/ativos/ativos.routes');
const visitasRoutes = require('./modules/visitas/visitas.routes');
const registrosRoutes = require('./modules/registros/registros.routes');
const syncRoutes = require('./modules/sync/sync.routes');

const app = express();

app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Servir uploads estáticos
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Rotas da API
app.use('/api/auth', orientadoresRoutes);
app.use('/api/escolas', escolasRoutes);
app.use('/api/ativos', ativosRoutes);
app.use('/api/visitas', visitasRoutes);
app.use('/api/registros', registrosRoutes);
app.use('/api/sync', syncRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', service: 'via-audit-api', time: new Date() });
});

app.use(errorHandler);

module.exports = app;
