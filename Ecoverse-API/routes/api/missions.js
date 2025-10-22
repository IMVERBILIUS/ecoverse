// Ecoverse-API/routes/api/missions.js

const express = require('express');
const router = express.Router();
const auth = require('../../middleware/auth'); 
const User = require('../../models/User');

// @route   POST api/missions/submit/deposit
// @desc    Accepts sorted trash quantities, calculates reward, and updates user profile.
// @access  Private
router.post('/submit/deposit', auth, async (req, res) => {
    
    const { ecoSpotId, quantities } = req.body; 

    if (!ecoSpotId || !quantities) {
        return res.status(400).json({ msg: 'Missing EcoSpot ID or quantities data.' });
    }
    
    // --- LOGIKA PERHITUNGAN REWARD ---
    let totalItems = 0;
    let totalXP = 0;
    let totalGP = 0;

    // Hitung reward berdasarkan item yang di-submit
    for (const type in quantities) {
        const count = quantities[type];
        if (typeof count === 'number' && count > 0) {
            totalItems += count;
            totalXP += count * 5;  // 5 XP per item
            totalGP += count * 10; // 10 GP per item
        }
    }

    if (totalItems === 0) {
        return res.status(400).json({ msg: 'No items recorded for deposit.' });
    }
    
    // Tambahkan base reward (misalnya untuk check-in)
    totalXP += 10;
    totalGP += 20;

    try {
        // Dapatkan user ID dari JWT token
        let user = await User.findById(req.user.id); 
        
        if (!user) {
            return res.status(404).json({ msg: 'User not found' });
        }

        // Update progress user
        user.XP += totalXP;
        user.greenPoints += totalGP;
        
        await user.save();

        res.json({ 
            msg: `Deposit successful! Total ${totalItems} items rewarded.`,
            xp: totalXP, 
            gp: totalGP,
            newXP: user.XP,
            newGP: user.greenPoints
        });
    } catch (err) {
        console.error('ERROR PROCESSING DEPOSIT (JWT MODE):', err.message);
        res.status(500).json({ msg: 'Server error during reward processing.' });
    }
});

module.exports = router;