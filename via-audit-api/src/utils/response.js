exports.success = (res, data = null, statusCode = 200) => {
  return res.status(statusCode).json({
    success: true,
    data,
  });
};

exports.error = (res, message = "Ocorreu um erro interno", statusCode = 400) => {
  return res.status(statusCode).json({
    success: false,
    error: message,
  });
};
