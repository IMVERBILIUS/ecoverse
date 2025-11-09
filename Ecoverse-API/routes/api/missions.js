// Ecoverse-API/routes/api/missions.js (Full Code - FINAL DEPOSIT)

const express = require('express');
const router = express.Router();
const auth = require('../../middleware/auth'); 
const User = require('../../models/User');
const Report = require('../../models/Report'); 

// --- Reward Constants ---
const BASE_XP_REWARD = 50;
const BASE_GP_REWARD = 50;
const POINTS_TO_XP_RATE = 1; 
const POINTS_TO_GP_RATE = 1; 


// @route   POST api/missions/submit/deposit
router.post('/submit/deposit', auth, async (req, res) => {
    
    const { ecoSpotId, quantities } = req.body; 
    const totalSimulatedPoints = quantities.total_points || 0; 

    if (!ecoSpotId) {
        return res.status(400).json({ msg: 'Missing EcoSpot ID.' });
    }
    if (totalSimulatedPoints <= 0) {
        return res.status(400).json({ msg: 'No points recorded. Add at least one item.' });
    }
    
    // --- LOGIKA PERHITUNGAN REWARD ---
    const xpFromPoints = totalSimulatedPoints * POINTS_TO_XP_RATE;
    const gpFromPoints = totalSimulatedPoints * POINTS_TO_GP_RATE;
    
    const totalXP = xpFromPoints + BASE_XP_REWARD;
    const totalGP = gpFromPoints + BASE_GP_REWARD;

    try {
        // 1. Dapatkan user ID
        let user = await User.findById(req.user.id); 
        if (!user) {
            return res.status(404).json({ msg: 'User not found' });
        }
        
        // 2. Gunakan $inc untuk semua pembaruan dalam satu operasi
        const updateQuery = { 
            $inc: { 
                XP: totalXP, 
                greenPoints: totalGP,
                totalCollected: totalSimulatedPoints // <-- FIELD BARU: Tambahkan total poin/berat
            }
        };

        await User.findByIdAndUpdate(req.user.id, updateQuery);

        res.json({ 
            msg: `Deposit success! Earned ${totalSimulatedPoints} points.`,
            xp: totalXP, 
            gp: totalGP,
        });
    } catch (err) {
        console.error('ERROR PROCESSING DEPOSIT (JWT MODE):', err.message);
        res.status(500).json({ msg: 'Server error during reward processing.' });
    }
});


// @route   POST api/missions/report-issue
router.post('/report-issue', auth, async (req, res) => {
    const { ecoSpotId, reportType, description } = req.body;
    
    if (!ecoSpotId || !reportType || !description) {
        return res.status(400).json({ msg: 'Missing required report fields.' });
    }

    try {
        const newReport = new Report({
            userId: req.user.id,
            ecoSpotId,
            reportType,
            description,
        });

        await newReport.save();

        res.json({ 
            msg: 'Issue reported successfully! Thank you for your help.', 
            reportId: newReport._id 
        });

    } catch (err) {
        console.error('ERROR SUBMITTING REPORT:', err.message);
        res.status(500).json({ msg: 'Server error during report submission.' });
    }
});


module.exports = router;