const express = require('express');
const homeController = require('../controllers/home.controller');

let router = express.Router();
router.get('/', homeController.home);
router.get('/products/products', homeController.getProducts);
router.post('/products/postfile', homeController.postFile);
router.get('/products/update', homeController.updateInventory);
router.post('/products/movement', homeController.moveWindow);

module.exports = router;