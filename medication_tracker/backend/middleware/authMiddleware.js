const jwt = require('jsonwebtoken');
const User = require('../models/User'); // Model for regular users
const Caregiver = require('../models/SimpleCaregiver'); // Model for caregivers
const Admin = require('../models/Admin'); // Model for admins
const AdminCaregiver = require('../models/SimpleCaregiver'); // Model for admin caregivers

// Middleware to authenticate the user based on JWT token
const authMiddleware = async (req, res, next) => {
  try {
    // Extract token from Authorization header
    const authHeader = req.header('Authorization');
    if (!authHeader) {
      console.error('Authentication failed: No Authorization header provided');
      return res.status(401).json({ error: 'Authorization header is required' });
    }

    const token = authHeader.replace('Bearer ', '');
    if (!token) {
      console.error('Authentication failed: Token missing in Authorization header');
      return res.status(401).json({ error: 'Token is required for authentication' });
    }

    // Decode and verify the token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    console.log('Token successfully decoded:', decoded);

    // Identify and validate the role from the decoded token
    switch (decoded.role) {
      case 'user': {
        const user = await User.findById(decoded.id).select('-password');
        if (!user) {
          console.error(`Authentication failed: User with ID ${decoded.id} not found`);
          return res.status(401).json({ error: 'User not found' });
        }

        console.log('Authenticated user:', {
          id: user._id,
          email: user.email,
          username: user.username,
        });

        req.user = { id: user._id, email: user.email, username: user.username };
        break;
      }

      case 'caregiver': {
        const caregiver = await Caregiver.findById(decoded.id).select('-password');
        if (!caregiver) {
          console.error(`Authentication failed: Caregiver with ID ${decoded.id} not found`);
          return res.status(401).json({ error: 'Caregiver not found' });
        }

        console.log('Authenticated caregiver:', {
          id: caregiver._id,
          email: caregiver.email,
          name: caregiver.name,
          relationshipToUser: caregiver.relationshipToUser,
        });

        req.caregiver = {
          id: caregiver._id,
          email: caregiver.email,
          name: caregiver.name,
          relationshipToUser: caregiver.relationshipToUser,
        };
        break;
      }

      case 'admin': {
        const admin = await Admin.findById(decoded.id).select('-password');
        if (!admin) {
          console.error(`Authentication failed: Admin with ID ${decoded.id} not found`);
          return res.status(401).json({ error: 'Admin not found' });
        }

        console.log('Authenticated admin:', {
          id: admin._id,
          email: admin.email,
          username: admin.username,
        });

        req.admin = { id: admin._id, email: admin.email, username: admin.username };
        break;
      }

      case 'adminCaregiver': {
        const adminCaregiver = await AdminCaregiver.findById(decoded.id).select('-password');
        if (!adminCaregiver) {
          console.error(`Authentication failed: AdminCaregiver with ID ${decoded.id} not found`);
          return res.status(401).json({ error: 'AdminCaregiver not found' });
        }

        console.log('Authenticated admin-assigned caregiver:', {
          id: adminCaregiver._id,
          email: adminCaregiver.email,
          name: adminCaregiver.caregiverName,
          linkedUser: adminCaregiver.userId,
        });

        req.adminCaregiver = {
          id: adminCaregiver._id,
          email: adminCaregiver.email,
          name: adminCaregiver.caregiverName,
          linkedUser: adminCaregiver.userId,
        };
        break;
      }

      default:
        console.error('Authentication failed: Invalid role specified in token');
        return res.status(401).json({ error: 'Invalid role specified in token' });
    }

    // Proceed to the next middleware or route handler
    next();
  } catch (error) {
    console.error('Authentication error:', error.message);

    // Handle specific JWT errors
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expired' });
    } else if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ error: 'Invalid token' });
    }

    res.status(500).json({ error: 'Internal server error during authentication' });
  }
};

module.exports = authMiddleware;
