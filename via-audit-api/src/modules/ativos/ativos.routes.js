const express = require('express');
const router = express.Router();
const controller = require('./ativos.controller');

router.get('/', controller.listar);

module.exports = router;
