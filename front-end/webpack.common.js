const path = require('path')

module.exports = {
    entry: {
        app: [
            './src/index.js'
        ]
    },

    output: {
        filename: 'app.js',
        path: path.resolve(__dirname, 'dist')
    },

    resolveLoader: {
        alias: {
            'elm-loader': path.join(__dirname, 'loaders', 'elmLoader.js')
        }
    }
};