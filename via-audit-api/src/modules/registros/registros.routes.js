const express = require('express');
const router = express.Router();
const controller = require('./registros.controller');
const upload = require('../../config/upload');

router.post(
  '/',
  upload.fields([
    { name: 'foto', maxCount: 1 },
    { name: 'foto2', maxCount: 1 },
    { name: 'foto3', maxCount: 1 },
  ]),
  controller.salvar
);
router.get('/validar-patrimonio', controller.validarPatrimonio);

module.exports = router;
