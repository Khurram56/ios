const Medication = require('../models/Medication');
const MedicationHistory = require('../models/MedicationHistory');

// Add Medication
exports.addMedication = async (req, res) => {
  try {
    const { name, dosage, frequency, specificTimes } = req.body;

    if (!name || !dosage || !frequency || !specificTimes || !Array.isArray(specificTimes)) {
      return res.status(400).json({ error: 'Name, dosage, frequency, and specificTimes are required and must be valid' });
    }

    // Save to Medications collection
    const newMedication = new Medication({
      user: req.user.id,
      name,
      dosage,
      frequency,
      specificTimes,
      remainingTimes: specificTimes, // Initialize remaining times with all specific times
    });

    await newMedication.save();

    // Save the same medication details to MedicationHistories collection
    const historyEntry = new MedicationHistory({
      user: req.user.id,
      action: 'ADD',
      medication: {
        name: newMedication.name,
        dosage: newMedication.dosage,
        frequency: newMedication.frequency,
        specificTimes: newMedication.specificTimes,
      },
    });

    await historyEntry.save();

    res.status(201).json({
      message: 'Medication added successfully',
      medication: newMedication,
    });
  } catch (error) {
    console.error('Error adding medication:', error.message);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Get Medications for a User
exports.getMedications = async (req, res) => {
  try {
    const medications = await Medication.find({ user: req.user.id });
    res.json(medications);
  } catch (error) {
    console.error('Error fetching medications:', error.message);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Edit Medication
exports.editMedication = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, dosage, frequency, specificTimes } = req.body;

    const updatedMedication = await Medication.findOneAndUpdate(
      { _id: id, user: req.user.id },
      { 
        name, 
        dosage, 
        frequency, 
        specificTimes,
        remainingTimes: specificTimes, // Reset remaining times when editing
        acknowledgedTimes: [], // Clear acknowledged times when editing
      },
      { new: true }
    );

    if (!updatedMedication) {
      return res.status(404).json({ error: 'Medication not found' });
    }

    res.json({ message: 'Medication updated successfully', medication: updatedMedication });
  } catch (error) {
    console.error('Error updating medication:', error.message);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Delete Medication
exports.deleteMedication = async (req, res) => {
  try {
    const { id } = req.params;

    const deletedMedication = await Medication.findOneAndDelete({ _id: id, user: req.user.id });
    if (!deletedMedication) {
      return res.status(404).json({ error: 'Medication not found' });
    }

    // Do NOT delete from history
    res.json({ message: 'Medication deleted successfully' });
  } catch (error) {
    console.error('Error deleting medication:', error.message);
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.logMedicationStatus = async (req, res) => {
  try {
    const { medicationId, status, timestamp } = req.body;

    if (!medicationId || !status || !timestamp) {
      return res.status(400).json({ error: 'Medication ID, status, and timestamp are required' });
    }

    const medication = await Medication.findOne({ _id: medicationId, user: req.user.id });
    if (!medication) {
      return res.status(404).json({ error: 'Medication not found' });
    }

    // Save the status in the MedicationHistory collection
    const historyEntry = new MedicationHistory({
      user: req.user.id,
      action: status.toUpperCase(),
      medication: {
        name: medication.name,
        dosage: medication.dosage,
        frequency: medication.frequency,
        specificTimes: medication.specificTimes,
      },
      timestamp, // Add timestamp explicitly
    });

    await historyEntry.save();

    res.status(200).json({ message: 'Medication status logged successfully', medication });
  } catch (error) {
    console.error('Error logging medication status:', error.message);
    res.status(500).json({ error: 'Internal server error' });
  }
};

