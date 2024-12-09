const express = require('express');
const Log = require('../models/logModel');
const router = express.Router();

// Endpoint to log medication status
router.post('/logMedicationStatus', async (req, res) => {
  try {
    console.log(`[DEBUG] Request received at /logMedicationStatus`);
    console.log(`[DEBUG] Request body:`, req.body);

    const { action, notificationId, medicationName, timestamp, nextNotificationTime } = req.body;

    if (!action || !notificationId || !medicationName || !timestamp) {
      return res.status(400).send({ success: false, message: 'Missing required fields' });
    }

    const log = new Log({
      action,
      notificationId,
      medicationName,
      timestamp: new Date(timestamp),
      nextNotificationTime: nextNotificationTime ? new Date(nextNotificationTime) : null,
    });

    await log.save();

    console.log(`[DEBUG] Log saved successfully:`, log);

    res.status(200).send({ success: true, message: 'Log added successfully' });
  } catch (error) {
    console.error(`[ERROR] Failed to save log:`, error.message);
    res.status(500).send({ success: false, error: error.message });
  }
});

module.exports = router;
