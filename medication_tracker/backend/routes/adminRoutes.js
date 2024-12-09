const express = require('express');
const router = express.Router();
const { registerAdmin, loginAdmin } = require('../controllers/adminController');
const { getUsersWithMedicationHistory } = require('../controllers/adminController'); // Import the new function

// Route to register an admin
router.post('/register', registerAdmin);

// Route for admin login (if needed)
router.post('/login', loginAdmin);

// Admin route to fetch all users and their medication history
router.get('/users-with-medications', getUsersWithMedicationHistory);

// Log request details for debugging
router.use((req, res, next) => {
    console.log(`Incoming request to /api/admin: ${req.method} ${req.url}`);
    next();
  });

module.exports = router;
