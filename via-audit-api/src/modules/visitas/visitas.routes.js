const express = require('express');
const router = express.Router();
const controller = require('./visitas.controller');
const upload = require('../../config/upload');

router.post('/iniciar', controller.iniciar);
router.post('/:visitaId/concluir', upload.single('assinatura'), controller.concluir);
router.get('/:visitaId/resumo', controller.resumo);

module.exports = router;
