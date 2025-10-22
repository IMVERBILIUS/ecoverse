// Ecoverse-API/models/CommunityEvent.js (Full Code - Address Only)

const mongoose = require('mongoose');

// GeoSchema dihapus

const CommunityEventSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  organizer: {
    type: String,
    default: 'Local Eco-Champion',
  },
  address: { // FIELD BARU: Ganti GeoJSON dengan String alamat
    type: String,
    default: 'TBA / Online',
  },
  eventDate: {
    type: Date,
    required: true,
  },
  participants: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  }],
  maxParticipants: {
    type: Number,
    default: 50,
  },
}, { timestamps: true });

module.exports = mongoose.model('CommunityEvent', CommunityEventSchema);