const express = require('express');
const { getMedicationHistory } = require('../controllers/medicationHistoryController');
const authMiddleware = require('../middleware/authMiddleware');
const User = require('../models/User');
const MedicationHistory = require('../models/MedicationHistory');

const router = express.Router();

// Route to fetch medication history
router.get('/', authMiddleware, getMedicationHistory);




  
module.exports = router;
