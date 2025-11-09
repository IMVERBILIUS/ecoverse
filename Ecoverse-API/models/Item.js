// Ecoverse-API/models/Item.js (Full Code)

const mongoose = require('mongoose');

const ItemSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true
  },
  description: {
    type: String,
    required: true,
  },
  type: { // E.g., 'boost', 'seed', 'potion', 'cosmetic'
    type: String,
    required: true,
  },
  costGP: { // Harga Green Points
    type: Number,
    default: 100,
  },
  effect: { // Deskripsi efek atau buff yang diberikan
    type: String,
    default: 'None',
  },
  icon: { // Path atau ID untuk ikon item di frontend
    type: String,
    default: 'default_item',
  },
}, { timestamps: true });

module.exports = mongoose.model('Item', ItemSchema);