const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const UserSchema = new mongoose.Schema({
    name: { type: String, required: true },
    dateOfBirth: { type: Date },
    contactDetails: { type: String, unique: true, required: true },
    username: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    caregivers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }], // linked caregivers
    role: { type: String, default: 'user' },
    emergencyContacts: [{ name: String, phone: String }],
}, { timestamps: true });

module.exports = mongoose.model('User', UserSchema);
