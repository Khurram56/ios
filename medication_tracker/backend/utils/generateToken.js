require('dotenv').config({ path: '../.env' });  // Adjust the path if needed
const jwt = require('jsonwebtoken');

// Log to check if JWT_SECRET is being loaded
console.log("JWT_SECRET from .env:", process.env.JWT_SECRET);

const userId = "user123";

const generateToken = (userId) => {
    return jwt.sign({ id: userId }, process.env.JWT_SECRET, { expiresIn: '28d' });
};

try {
    const token = generateToken(userId);
    console.log("Generated JWT Token:", token);
} catch (error) {
    console.error("Error generating JWT:", error.message);
}
