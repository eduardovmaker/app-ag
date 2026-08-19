const { error } = require('../utils/response');

module.exports = (err, req, res, next) => {
  console.error('[API Error]', err);
  const status = err.statusCode || 500;
  
  // Sanitizar mensagens de erro internas em ambiente de produção
  let message = err.message || 'Erro interno no servidor';
  if (status === 500 && process.env.NODE_ENV === 'production') {
    message = 'Erro interno no servidor. Por favor, tente novamente mais tarde.';
  }
  
  return error(res, message, status);
};
