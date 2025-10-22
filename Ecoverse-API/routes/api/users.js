// Ecoverse-API/routes/api/users.js
const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// PENTING: GANTI INI DENGAN KUNCI RAHASIA ANDA! (HARUS SAMA DENGAN auth.js)
const JWT_SECRET = 'supersecretkeyforEcoverse2025'; 

// Import model User
const User = require('../../models/User');

// @route   POST api/users/register
router.post('/register', async (req, res) => {
  const { username, email, password } = req.body;
  try {
    let user = await User.findOne({ email });
    if (user) return res.status(400).json({ msg: 'User already exists' });
    
    user = new User({ username, email, password });
    
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(password, salt);
    await user.save();

    const payload = { user: { id: user.id } };

    jwt.sign(
      payload,
      JWT_SECRET, 
      { expiresIn: '5 days' },
      (err, token) => {
        if (err) throw err;
        res.json({ token }); 
      }
    );
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});


// @route   POST api/users/login
router.post('/login', async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) return res.status(400).json({ msg: 'Email and password are required' });

    try {
        // FIX: select('+password') ensures the hash is available for comparison
        let user = await User.findOne({ email }).select('+password'); 
        
        if (!user) return res.status(400).json({ msg: 'Invalid Credentials' });

        const isMatch = await bcrypt.compare(password, user.password);
        
        if (!isMatch) return res.status(400).json({ msg: 'Invalid Credentials' });

        const payload = { user: { id: user.id } };

        jwt.sign(
            payload,
            JWT_SECRET, // Menggunakan kunci rahasia yang sama
            { expiresIn: '5 days' },
            (err, token) => {
                if (err) throw err;
                res.json({ token });
            }
        );
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
});

module.exports = router;