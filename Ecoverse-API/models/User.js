// Ecoverse-API/models/User.js (Full Code - FINAL)

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
  diamonds: { // Mata uang premium
    type: Number,
    default: 0,
  },
  currentRank: {
    type: String,
    default: 'Seeder' 
  },
  distanceWalked: { // Jarak total berjalan (dalam meter)
    type: Number,
    default: 0
  },
  totalCollected: { // Total poin/berat yang dikumpulkan (untuk achievement/quest)
    type: Number,
    default: 0,
  },
  motto: { // Personal Motto
    type: String,
    default: 'Turning steps into sustainability.',
  },
  avatarId: { // ID Avatar untuk menampilkan ikon
    type: String,
    default: 'person', 
  },
  
  // --- SOSIAL/FRIENDS DATA (NEW ADDITIONS) ---
  friends: [{ // Daftar ID pengguna yang sudah menjadi teman
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  }],
  friendRequests: [{ // Daftar ID pengguna yang mengirim permintaan
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  }],
  // --- END SOSIAL/FRIENDS DATA ---

  // Data Plant Pet (referensi)
  plantPets: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'PlantPet' 
  }],
  inventory: { // General Inventory (e.g., item boosts by name)
    type: [String],
    default: []
  }
}, { timestamps: true });

module.exports = mongoose.model('User', UserSchema);