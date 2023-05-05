const homeRoutes = require('./home.routes');

module.exports.initRoutes = (app) => {
    app.use('/', homeRoutes);
    app.use((req, res) => {
        res.sendStatus(404);
    });
}