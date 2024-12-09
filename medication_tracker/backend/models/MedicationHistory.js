const mongoose = require('mongoose');

const MedicationHistorySchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  action: { type: String, required: true }, // Action type: ADD, EDIT, DELETE
  medication: {
    name: { type: String, required: true },
    dosage: { type: String, required: true },
    frequency: { type: String, required: true },
    specificTimes: { type: [String] },
  },
  timestamp: { type: Date, default: Date.now },
});

module.exports = mongoose.model('MedicationHistory', MedicationHistorySchema);
