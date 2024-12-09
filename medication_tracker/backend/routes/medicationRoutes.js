const express = require('express');
const { addMedication, getMedications, editMedication, deleteMedication } = require('../controllers/medicationController');
const authMiddleware = require('../middleware/authMiddleware'); // Assuming you have an auth middleware
const medicationController = require('../controllers/medicationController');

const router = express.Router();

router.post('/medication', authMiddleware, addMedication);
router.get('/medications', authMiddleware, getMedications);
router.put('/medication/:id', authMiddleware, editMedication);
router.delete('/medication/:id', authMiddleware, deleteMedication);
router.post('/log-medication-status', authMiddleware, medicationController.logMedicationStatus);


module.exports = router;
