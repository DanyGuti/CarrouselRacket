const path = require('path');
const express = require('express');
const bodyParser = require('body-parser');
const app = express();

const { initRoutes } = require('./routes');

const PORT = 4000;

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.set('view engine', 'ejs');
app.set('views', 'views/partials');

app.use(express.static(path.join(__dirname, 'public')));


initRoutes(app);
app.listen(PORT, () => {
    console.log(`Server listening in http://localhost:${PORT}`);
});