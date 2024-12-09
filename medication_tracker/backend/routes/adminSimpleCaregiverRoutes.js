const express = require('express');
const { addSimpleCaregiver } = require('../controllers/adminSimpleCaregiverController');
const { assignCaregiverToUser, getUsersAndCaregivers } = require('../controllers/adminSimpleCaregiverController');
const { loginCaregiver } = require('../controllers/adminSimpleCaregiverController'); 
const { caregiverDashboard } = require('../controllers/adminSimpleCaregiverController'); // Import the controller
const authenticateCaregiver = require('../middleware/authMiddleware'); // Assuming this is the correct path

const router = express.Router();

// Add a caregiver (admin action)
router.post('/add-caregiver', addSimpleCaregiver);

// Assign caregiver to user
router.post('/assign-caregiver', assignCaregiverToUser);

// Fetch all users and caregivers
router.get('/fetch-users-caregivers', getUsersAndCaregivers);

// Route to login a caregiver
router.post('/login', loginCaregiver);  // This is the login route

router.get('/dashboard', authenticateCaregiver, caregiverDashboard);


module.exports = router;
