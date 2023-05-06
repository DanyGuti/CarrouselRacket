const file = require('../public/scripts/file')
const path = require('path');
const filePath = path.join(__dirname, '/../index/Inventory.txt');
const { spawn } = require('child_process');

exports.home = async(req, res) => {
    const inventory = await file.readInventory();
    const products = Object.keys(inventory);
    const inventoryJson = JSON.stringify(inventory);
    res.render(__dirname + '/../views/main', {
        products : products,
        inventory: inventoryJson
    });
}

exports.updateInventory = async (req, res) => {
    const inventory = await file.readInventory();
    let key = req.query.product;
    let filterInv = inventory[key];
    let productObjects = filterInv.map((str) => {
        const [product, price, index, quantity] = str.split(' ');
        return {
            product,
            price: parseFloat(price),
            index: parseInt(index),
            quantity: parseInt(quantity)
        };
    });
    res.status(200).json({productObjects: productObjects});
}

exports.getProducts = async(req, res) => {
    let key = req.query.key;
    let inventory = JSON.parse(req.query.inventory);
    let filterInv = inventory[key];
    let productObjects = filterInv.map((str) => {
        const [product, price, index, quantity] = str.split(' ');
        return {
            product,
            price: parseFloat(price),
            index: parseInt(index),
            quantity: parseInt(quantity)
        };
    });
    res.status(200).json({productObjects: productObjects});
}

exports.postFile = async (req, res) => {
    let addTransaction = req.body.addTransaction;
    let retireTransaction = req.body.retireTransaction;
    const arguments = [filePath, addTransaction.join(','), retireTransaction.join(',')];
    console.log(...arguments);
    let dataTransaction = '';
    console.log(addTransaction);
    const childProcess = spawn(process.env.RACKET_PATH, [path.join(__dirname, '/../index/SP_P2.rkt'), ...arguments]);
    
    // Handle the output of the child process
    childProcess.stdout.on('data', (data) => {
        dataTransaction += data.toString();
    });

    childProcess.stderr.on('data', (data) => {
        console.error(`stderr: ${data}`);
    });

    childProcess.on('close', (code) => {
        res.status(200).json({ data: dataTransaction });
        console.log(`child process exited with code ${code}`);
    });
}