// Ecoverse-API/models/User.js (Full Code)

const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true,
    unique: true
  },
  email: {
    type: String,
    required: true,
    unique: true
  },
  password: {
    type: String,
    required: true,
    select: false, 
  },
  // Data inti gamifikasi Ecoverse
  XP: {
    type: Number,
    default: 0
  },
  greenPoints: {
    type: Number,
    default: 0 
  },
  currentRank: {
    type: String,
    default: 'Seeder' 
  },
  distanceWalked: { // Jarak total berjalan (dalam meter)
    type: Number,
    default: 0
  },
  motto: { // Personal Motto
    type: String,
    default: 'Turning steps into sustainability.',
  },
  // FIELD BARU: ID Avatar untuk menampilkan ikon
  avatarId: { 
    type: String,
    default: 'person', 
  },
  
  // Data Plant Pet (referensi)
  plantPets: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'PlantPet' 
  }],
  inventory: { 
    type: [String],
    default: []
  }
}, { timestamps: true });

module.exports = mongoose.model('User', UserSchema);