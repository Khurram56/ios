const mongoose = require('mongoose');

const logSchema = new mongoose.Schema({
  action: { type: String, required: true }, // e.g., "acknowledged", "snoozed", "missed"
  notificationId: { type: String, required: true }, // Notification ID
  medicationName: { type: String, required: true }, // Name of the medication
  timestamp: { type: Date, required: true }, // Timestamp of the action
  nextNotificationTime: { type: Date }, // Applicable only for snoozed actions
});

module.exports = mongoose.model('Log', logSchema);
