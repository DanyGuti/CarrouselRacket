const fs = require('fs');
const readline = require('readline');
const path = require('path');
const filePath = path.join(__dirname, '/../../index/Inventory.txt');

async function readInventory() {
    const inventory = {};
    const fileStream = fs.createReadStream(filePath);

    const rl = readline.createInterface({
        input: fileStream,
        crlfDelay: Infinity
    });
    let lineNum = 0;
    for await (const line of rl) {
        const groupIndex = Math.floor(lineNum / 5);
        const key = String.fromCharCode(65 + groupIndex);
        if (!inventory[key]) {
            inventory[key] = [];
        }
        inventory[key].push(line);
        lineNum++;
    }

    return inventory;
}

module.exports = {
    readInventory
};