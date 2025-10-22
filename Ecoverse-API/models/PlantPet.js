// Ecoverse-API/models/PlantPet.js (Full Code)

const mongoose = require('mongoose');

const PlantPetSchema = new mongoose.Schema({
  ownerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  name: {
    type: String,
    default: 'Eco Seedling',
  },
  type: {
    type: String,
    default: 'Common Wildflower',
  },
  rarity: {
    type: String,
    enum: ['Basic', 'Rare', 'Exotic'],
    default: 'Basic',
  },
  growthStage: {
    type: Number,
    default: 1,
    min: 1,
  },
  distanceRequired: { // Jarak yang dibutuhkan untuk stage berikutnya (dalam meter)
    type: Number,
    default: 1000,
  },
  buffs: {
    type: Map, 
    of: mongoose.Schema.Types.Mixed,
    default: { "XP_Boost": 1.0, "GP_Bonus": 0 },
  },
  // FIELD BARU: Menandai pet mana yang sedang aktif
  isActive: { 
    type: Boolean,
    default: false, 
  }
}, { timestamps: true });

module.exports = mongoose.model('PlantPet', PlantPetSchema);