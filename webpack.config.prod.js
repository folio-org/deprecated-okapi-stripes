// Common Webpack configuration for building Stripes for production

const webpack = require('webpack');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const ExtractTextPlugin = require("extract-text-webpack-plugin");

module.exports = {
  plugins: [
    new webpack.DefinePlugin({
      'OKAPI_URL': false,
      'process.env': {
        'NODE_ENV': JSON.stringify('production')
      }
    }),
    /* new webpack.optimize.UglifyJsPlugin({
      compressor: {
        warnings: false
      }
    }),
    */
    new ExtractTextPlugin({filename: "global.css", allChunks: true }),
    new CopyWebpackPlugin([
      { from:bootstrapDist, to:'bootstrap'},
      { from: path.join(__dirname, 'index.html'), to:'index.html'},
    ])
  ]
};
