// Ecoverse-API/models/Report.js (Full Code)

const mongoose = require('mongoose');

const ReportSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  ecoSpotId: {
    type: String, // ID EcoSpot yang dilaporkan
    required: true,
  },
  reportType: { // E.g., 'Full Bin', 'Damage', 'Litter'
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  status: { // E.g., 'New', 'In Progress', 'Resolved'
    type: String,
    default: 'New',
  }
}, { timestamps: true });

module.exports = mongoose.model('Report', ReportSchema);