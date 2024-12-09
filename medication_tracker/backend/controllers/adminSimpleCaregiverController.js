const SimpleCaregiver = require('../models/SimpleCaregiver');
const User = require('../models/User');
const jwt = require('jsonwebtoken');  // <-- Importing the jsonwebtoken module
const MedicationHistory = require('../models/MedicationHistory'); 


// Caregiver Registration
exports.addSimpleCaregiver = async (req, res) => {
  try {
    const { caregiverName, email, phoneNumber, relationshipToUser, password } = req.body;

    // Validate input
    if (!caregiverName || !email || !phoneNumber || !relationshipToUser || !password) {
      return res.status(400).json({ error: 'All fields are required: name, email, phoneNumber, and relationshipToUser.' });
    }

    // Check if caregiver email already exists
    const existingCaregiver = await SimpleCaregiver.findOne({ email });
    if (existingCaregiver) {
      return res.status(400).json({ error: 'Caregiver already exists' });
    }

    // Create a new caregiver (password is stored in plain text here)
    const caregiver = new SimpleCaregiver({
      caregiverName,
      email,
      phoneNumber,
      relationshipToUser,
      password, // Save the password directly (as plain text)
    });

    // Save caregiver to the database
    await caregiver.save();

    res.status(201).json({ message: 'Caregiver added successfully', caregiver });
  } catch (error) {
    console.error('Error adding caregiver:', error.message);
    res.status(500).json({ error: 'Internal server error' });
  }
};


exports.assignCaregiverToUser = async (req, res) => {
  try {
    const { caregiverId, userId } = req.body;

    // Validate caregiver
    const caregiver = await SimpleCaregiver.findById(caregiverId);
    if (!caregiver) {
      return res.status(404).json({ error: 'Caregiver not found' });
    }

    // Validate user
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Assign caregiver to user
    caregiver.userId = userId;
    await caregiver.save();

    res.status(200).json({ message: 'Caregiver assigned to user successfully', caregiver });
  } catch (error) {
    console.error('Error assigning caregiver:', error.message);
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.getUsersAndCaregivers = async (req, res) => {
  try {
    const users = await User.find();
    const caregivers = await SimpleCaregiver.find();

    res.status(200).json({ users, caregivers });
  } catch (error) {
    console.error('Error fetching data:', error.message);
    res.status(500).json({ error: 'Internal server error' });
  }
};


// Caregiver login
exports.loginCaregiver = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Find the caregiver by email
    const caregiver = await SimpleCaregiver.findOne({ email });
    if (!caregiver) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    // Check if password matches
    if (caregiver.password !== password) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    // Generate JWT token for the caregiver
    const token = jwt.sign(
      { id: caregiver._id, email: caregiver.email, role: 'caregiver' },
      process.env.JWT_SECRET,
      { expiresIn: '28d' }
    );

    res.status(200).json({ message: 'Login successful', token });
  } catch (error) {
    console.error('Error logging in caregiver:', error.message);
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.caregiverDashboard = async (req, res) => {
  try {
    const caregiverId = req.caregiver.id;  // Fetch caregiver ID from token

    // Find caregiver by ID
    const caregiver = await SimpleCaregiver.findById(caregiverId).populate('userId');
    if (!caregiver) {
      return res.status(404).json({ error: 'Caregiver not found' });
    }

    // Fetch all medications linked to any user
    const medications = await MedicationHistory.find();

    res.status(200).json({
      caregiverName: caregiver.caregiverName,
      user: caregiver.userId,
      medicationHistory: medications,
    });
  } catch (error) {
    console.error('Error fetching caregiver dashboard:', error.message);
    res.status(500).json({ error: 'Internal server error' });
  }
};
