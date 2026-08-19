const { error } = require('../utils/response');

module.exports = (err, req, res, next) => {
  console.error('[API Error]', err);
  const status = err.statusCode || 500;
  const message = err.message || 'Erro interno no servidor';
  return error(res, message, status);
};
