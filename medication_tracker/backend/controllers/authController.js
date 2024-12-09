const jwt = require('jsonwebtoken');
const User = require('../models/User');
const MedicationHistory = require('../models/MedicationHistory');

// User Registration Handler
const registerUser = async (req, res) => {
  try {
    const { name, dateOfBirth, contactDetails, username, password } = req.body;

    // Validate required fields
    if (!name || !username || !password || !contactDetails) {
      return res.status(400).json({ error: 'Name, username, password, and contact details are required' });
    }

    // Check if contact number already exists
    const existingContact = await User.findOne({ contactDetails });
    if (existingContact) {
      return res.status(400).json({ error: 'Contact number already exists' });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ username });
    if (existingUser) {
      return res.status(400).json({ error: 'Username already taken' });
    }

    // Save user with plain password (NOT recommended for real apps, should be hashed)
    const user = new User({
      name,
      dateOfBirth,
      contactDetails,
      username,
      password, // Plain text password (you should hash it before storing in real applications)
    });

    await user.save();
    res.status(201).json({ message: 'User registered successfully' });
  } catch (error) {
    console.error('Error during user registration:', error.message);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// User Login Handler
const loginUser = async (req, res) => {
  try {
    const { username, password } = req.body;

    // Validate input fields
    if (!username || !password) {
      return res.status(400).json({ error: 'Username and password are required' });
    }

    // Find user by username
    const user = await User.findOne({ username });
    if (!user) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    // Compare plain text passwords (in production, passwords should be hashed)
    if (user.password !== password) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    // Generate a JWT token with user info
    const token = jwt.sign(
      { id: user._id, role: user.role },  // Include user id and role in the payload
      process.env.JWT_SECRET,
      { expiresIn: '28d' } // Token expiration (28 days in this case)
    );

    res.json({ message: 'Login successful', token });
  } catch (error) {
    console.error('Error during user login:', error.message);
    res.status(500).json({ error: 'Internal server error' });
  }
};

// Function to fetch all users and their medication history
exports.getUsersWithMedicationHistory = async (req, res) => {
  try {
    // Fetch all users
    const users = await User.find();

    // Fetch all medication history records (assuming you have a field userId in MedicationHistory)
    const medicationHistories = await MedicationHistory.find();

    // Combine users with their respective medication histories
    const usersWithHistories = users.map(user => {
      const userMedicationHistory = medicationHistories.filter(medHistory => medHistory.userId.toString() === user._id.toString());
      return {
        ...user.toObject(),
        medicationHistory: userMedicationHistory
      };
    });

    // Return combined data
    res.status(200).json({ usersWithHistories });
  } catch (error) {
    console.error('Error fetching data:', error.message);
    res.status(500).json({ error: 'Internal server error' });
  }
};

module.exports = { registerUser, loginUser };
