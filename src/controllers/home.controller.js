const fs = require('fs');
const path = require('path');
const readline = require('readline');

const filePath = path.join(__dirname, '/../index/Inventory.txt');
const fileStream = fs.createReadStream(filePath);

exports.home = async(req, res) => {
    let data_inventory = [];
    const rl = readline.createInterface({
        input: fileStream,
        crlfDelay: Infinity
    });
    rl.on('line',(line, index) => {
        data_inventory.push(line);
    });
    rl.on('close',() => {
        const inventory = {};
        data_inventory.forEach((line, index) => {
            const groupIndex = Math.floor(index / 5);
            const key = String.fromCharCode(65 + groupIndex);
            if (!inventory[key]) {
                inventory[key] = [];
            }
            inventory[key].push(line);
        });
        let products = Object.keys(inventory);
        const inventoryJson = JSON.stringify(inventory);
        res.render(__dirname + '/../views/main', {
            products : products,
            inventory: inventoryJson
        })
    });
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

exports.postFile = async(req, res) => {
    let transactions = req.body;
    console.log(transactions);
    res.status(200).json({msg:'success'});
}