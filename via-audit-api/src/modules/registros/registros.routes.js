const express = require('express');
const router = express.Router();
const controller = require('./registros.controller');
const upload = require('../../config/upload');

router.post('/', upload.single('foto'), controller.salvar);
router.get('/validar-patrimonio', controller.validarPatrimonio);

module.exports = router;
