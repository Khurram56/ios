const mongoose = require('mongoose');

const simpleCaregiverSchema = new mongoose.Schema({
  caregiverName: { type: String, required: true }, // Ensure this is required
  email: { type: String, required: true, unique: true },
  phoneNumber: { type: String, required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null },
  password: { type: String, required: true },
  relationshipToUser: { type: String, required: true },
});

module.exports = mongoose.model('SimpleCaregiver', simpleCaregiverSchema);
