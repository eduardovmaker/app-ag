const express = require('express');
const router = express.Router();
const controller = require('./escolas.controller');

router.get('/', controller.listar);

module.exports = router;
