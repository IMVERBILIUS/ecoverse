// Ecoverse-API/routes/api/quests.js (Full Code - FINAL FILTERING)

const express = require('express');
const router = express.Router();
const auth = require('../../middleware/auth'); 
const Quest = require('../../models/Achievement'); // NOTE: Using Achievement model for Quest data
const User = require('../../models/User'); 

// @route   GET api/quests/active
// @desc    Get all active daily/weekly quests and the user's current progress stats
// @access  Private
router.get('/active', auth, async (req, res) => {
    try {
        const userId = req.user.id;
        
        // 1. Ambil Misi yang Aktif (Hanya Daily dan Weekly)
        const quests = await Quest.find({ 
            $or: [ // Memfilter data yang hanya bertipe Daily atau Weekly
                { type: "Daily" }, 
                { type: "Weekly" }
            ],
            // isActive: true // Jika Anda punya field isActive di DB
        });

        // 2. Ambil Statistik Kritis Pengguna
        const userStats = await User.findById(userId).select('distanceWalked XP greenPoints totalCollected eventsJoined currentRank'); 

        if (!userStats) {
            return res.status(404).json({ msg: 'User statistics not found.' });
        }

        // --- MAPPING STATISTIK ---
        const stats = {
            distanceWalked: userStats.distanceWalked || 0,
            totalCollected: userStats.totalCollected || 0, 
            eventsJoined: 0, 
            currentLevel: Math.floor(userStats.XP / 1000) + 1,
        };
        // --- AKHIR MAPPING STATISTIK ---


        res.json({
            quests: quests, // Hanya berisi Daily/Weekly Quests
            userStats: stats, 
        });

    } catch (err) {
        console.error('ERROR FETCHING QUESTS & STATS:', err.message);
        res.status(500).json({ msg: 'Server error when fetching quests.' });
    }
});

module.exports = router;