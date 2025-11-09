// Ecoverse-API/models/Achievement.js (Full Code)

const mongoose = require('mongoose');

const AchievementSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  criteria: { // E.g., 'collect_kg', 'walk_m', 'events_joined', 'level'
    type: String,
    required: true,
  },
  threshold: { // Nilai target (misalnya 1000 meter, 5 event)
    type: Number,
    required: true,
  },
  gpReward: {
    type: Number,
    default: 0,
  },
  badgeIcon: { // Path atau ID ke icon asset
    type: String,
    default: 'star',
  },
}, { timestamps: true });

module.exports = mongoose.model('Achievement', AchievementSchema);