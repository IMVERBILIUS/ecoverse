const mongoose = require('mongoose');

const QuestSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
  },
  type: {
    type: String,
    enum: ['Daily', 'Weekly', 'Event'],
    required: true,
  },
  objectiveType: {
    type: String,
    enum: ['walkDistance', 'recycleCount', 'reportBin'],
    required: true,
  },
  targetValue: {
    type: Number,
    required: true,
    min: 1,
  },
  xpReward: {
    type: Number,
    default: 10,
  },
  gpReward: {
    type: Number,
    default: 20,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
}, { timestamps: true });

module.exports = mongoose.model('Quest', QuestSchema);