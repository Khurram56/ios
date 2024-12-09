const MedicationHistory = require('../models/MedicationHistory');

exports.getMedicationHistory = async (req, res) => {
  try {
    console.log(`Fetching history for user ID: ${req.user.id}`);
    const history = await MedicationHistory.find({ user: req.user.id }).sort({ timestamp: -1 });

    if (history.length === 0) {
      return res.status(200).json({ message: 'No medication history available', history: [] });
    }

    res.status(200).json(history);
  } catch (error) {
    console.error('Error fetching medication history:', error.message);
    res.status(500).json({ error: 'Internal server error' });
  }
};
