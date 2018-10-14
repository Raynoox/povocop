var webpack = require('webpack');

module.exports = {
  entry: {
    app: [
      'babel-polyfill',
      './web/static/js/index.js'
    ]
  },
  output: {
    path: './web/static/assets/',
    filename: 'bundle.js'
  },
  module: {
    loaders: [
      {
        test: /\.jsx?$/,
        exclude: /node_modules/,
        loader: "babel",
        query:
        {
          presets:['es2015']
        }
      }
    ]
  }
};
