const mongoose = require('mongoose');

const MedicationSchema = new mongoose.Schema({
  user: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true 
  },
  name: { 
    type: String, 
    required: true 
  },
  dosage: { 
    type: String, 
    required: true 
  },
  frequency: { 
    type: String, 
    required: true 
  },
  specificTimes: { 
    type: [String], // ISO 8601 date-time strings
    required: true 
  },
  remainingTimes: { 
    type: [String], // Tracks which times for the day are still pending
    default: []
  },
  acknowledgedTimes: { 
    type: [String], // Tracks which times have been acknowledged
    default: []
  },
  dailyReset: { 
    type: Boolean, 
    default: true // Indicates if the schedule resets daily
  }
}, { 
  timestamps: true // Automatically adds createdAt and updatedAt fields
});

module.exports = mongoose.model('Medication', MedicationSchema);
