const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const path = require('path');
const errorHandler = require('./middlewares/errorHandler');
const auth = require('./middlewares/auth');

const orientadoresRoutes = require('./modules/orientadores/orientadores.routes');
const escolasRoutes = require('./modules/escolas/escolas.routes');
const ativosRoutes = require('./modules/ativos/ativos.routes');
const visitasRoutes = require('./modules/visitas/visitas.routes');
const registrosRoutes = require('./modules/registros/registros.routes');
const syncRoutes = require('./modules/sync/sync.routes');
const adminRoutes = require('./modules/admin/admin.routes');

const app = express();

// Proteção de HTTP Headers com Helmet
app.use(helmet({ crossOriginResourcePolicy: false }));

// Configuração segura de CORS
app.use(cors());

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Rate Limiter para proteção contra ataques de força bruta no Login
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 30, // Máximo 30 tentativas por IP por janela
  message: { success: false, error: 'Muitas tentativas de login. Por favor, tente novamente em 15 minutos.' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Servir uploads estáticos
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Rotas públicas com Rate Limiter
app.use('/api/auth/login', loginLimiter);
app.use('/api/auth', orientadoresRoutes);

// Rotas protegidas por autenticação JWT
app.use('/api/escolas', auth, escolasRoutes);
app.use('/api/ativos', auth, ativosRoutes);
app.use('/api/visitas', auth, visitasRoutes);
app.use('/api/registros', auth, registrosRoutes);
app.use('/api/sync', auth, syncRoutes);
app.use('/api/admin', auth, adminRoutes);

// Health check público
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', service: 'via-audit-api', time: new Date() });
});

app.use(errorHandler);

module.exports = app;
