const jwt = require('jsonwebtoken');
const Admin = require('../models/Admin'); // Assuming you have a model for Admin
const bcrypt = require('bcrypt');
const User = require('../models/User');
const MedicationHistory = require('../models/MedicationHistory');


// Admin Registration
exports.registerAdmin = async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // Check if admin exists
    const existingAdmin = await Admin.findOne({ email });
    if (existingAdmin) {
      return res.status(400).json({ error: 'Admin already exists' });
    }

    // Hash password before saving
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create new admin
    const newAdmin = new Admin({
      username,
      email,
      password: hashedPassword,
      
    });

    await newAdmin.save();

    // Generate token for admin
    const token = jwt.sign({ id: newAdmin._id }, process.env.JWT_SECRET, { expiresIn: '30d' });

    return res.status(201).json({ message: 'Admin registered successfully', token });

  } catch (error) {
    console.error('Error registering admin:', error.message);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Admin Login (if needed)
exports.loginAdmin = async (req, res) => {
  try {
    const { email, password } = req.body;

    const admin = await Admin.findOne({ email });
    if (!admin) {
      return res.status(400).json({ error: 'Admin not found' });
    }

    const isMatch = await bcrypt.compare(password, admin.password);
    if (!isMatch) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    // Generate token
    const token = jwt.sign({ id: admin._id }, process.env.JWT_SECRET, { expiresIn: '30d' });

    res.status(200).json({ message: 'Login successful', token });

  } catch (error) {
    console.error('Error logging in admin:', error.message);
    res.status(500).json({ error: 'Internal server error' });
  }
};

exports.getUsersWithMedicationHistory = async (req, res) => {
  try {
    // Fetch all users
    const users = await User.find();

    // Fetch all medication history records and populate the user reference
    const medicationHistories = await MedicationHistory.find().populate('user', 'name username contactDetails'); // Populate the user data

    // Combine users with their respective medication histories
    const usersWithHistories = users.map(user => {
      // Filter medication histories for this user
      const userMedicationHistory = medicationHistories.filter(medHistory => medHistory.user._id.toString() === user._id.toString());

      return {
        ...user.toObject(),
        medicationHistory: userMedicationHistory,
      };
    });

    // Return the combined data
    res.status(200).json({ usersWithHistories });
  } catch (error) {
    console.error('Error fetching data:', error.message);
    res.status(500).json({ error: 'Internal server error' });
  }
};
