const express = require('express');
const connectDB = require('./config/db');
const cors = require('cors');




require('dotenv').config();


const authRoutes = require('./routes/authRoutes');
const medicationRoutes = require('./routes/medicationRoutes');
const historyRoutes = require('./routes/historyRoutes');
const logs = require('./routes/logRoutes'); // Ensure the correct name is used
const authenticateCaregiver = require('./middleware/authMiddleware');
const adminRoutes = require('./routes/adminRoutes');
const adminSimpleCaregiverRoutes = require('./routes/adminSimpleCaregiverRoutes');


const app = express();

// Middleware
app.use(cors());
app.use(express.json());


// Connect to Database
connectDB();

// Add a simple middleware to log each request for debugging
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// Routes
app.use('/api/auth', authRoutes); // Mount auth routes
app.use('/api', medicationRoutes);
app.use('/api/medicationHistory', historyRoutes);
app.use('/api', logs); // Using the correct variable name
app.use('/api/admin', adminRoutes); 
app.use('/api/simple-caregivers', adminSimpleCaregiverRoutes);
app.use('/api', authRoutes);  
app.use('/api/caregivers', adminSimpleCaregiverRoutes);




console.log('Log routes mounted at /api');

// 404 Error Handling
app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

// Error Handling Middleware
app.use((err, req, res, next) => {
  console.error('Error:', err.message);
  res.status(500).json({ error: 'Internal server error' });
});

app.use((req, res, next) => {
  console.log(`[DEBUG] Incoming Request - ${req.method}: ${req.url}`);
  console.log(`[DEBUG] Request Body:`, req.body);
  next();
});

app.get('/api/caregiver-dashboard', authenticateCaregiver, (req, res) => {
  res.status(200).json({ message: 'Welcome to the caregiver dashboard' });
});

app.get('/api/medicationHistory', async (req, res) => {
  try {
    const medications = await MedicationHistory.find(); // Fetch all medication history
    res.status(200).json({ medications });
  } catch (err) {
    console.error('Error fetching medication history:', err.message);
    res.status(500).json({ error: 'Failed to fetch medication history' });
  }
});


// Start Server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
