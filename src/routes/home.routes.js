const express = require('express');
const homeController = require('../controllers/home.controller');

let router = express.Router();
router.get('/', homeController.home);
router.get('/products/products', homeController.getProducts);
router.post('/products/postfile', homeController.postFile);

module.exports = router;