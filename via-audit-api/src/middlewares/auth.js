const { error } = require('../utils/response');

module.exports = (req, res, next) => {
  // Middleware de verificação simples de auth/PIN caso necessário
  next();
};
