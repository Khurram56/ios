const express = require('express');
const router = express.Router();
const { registerUser, loginUser } = require('../controllers/authController');



// Log request details for debugging
router.use((req, res, next) => {
  console.log(`Incoming request to /api/auth: ${req.method} ${req.url}`);
  next();
});

// Registration route
router.post('/register', registerUser);

// Login route
router.post('/login', loginUser);

module.exports = router;
