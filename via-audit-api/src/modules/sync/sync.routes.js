const express = require('express');
const router = express.Router();
const controller = require('./sync.controller');

router.post('/upload', controller.uploadBatch);

module.exports = router;
