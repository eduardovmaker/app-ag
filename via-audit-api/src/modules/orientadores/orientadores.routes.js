const express = require('express');
const router = express.Router();
const controller = require('./orientadores.controller');

router.post('/login', controller.login);

module.exports = router;
