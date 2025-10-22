// Ecoverse-API/routes/api/leaderboards.js (Full Code)

const express = require('express');
const router = express.Router();
const auth = require('../../middleware/auth'); 
const User = require('../../models/User');

// @route   GET api/leaderboards/top-users
// @desc    Get top users based on Green Points (GP)
// @access  Private
router.get('/top-users', auth, async (req, res) => {
    // req.query bisa digunakan untuk filter regional di masa depan (e.g., ?region=city)
    // Untuk MVP, kita ambil 50 teratas secara global
    const { limit = 50, category = 'GP' } = req.query;
    
    // Sort field based on category (default to greenPoints)
    let sortField = 'greenPoints';
    if (category === 'XP') {
        sortField = 'XP';
    } 
    // TODO: Di masa depan, tambahkan filter kategori lain seperti 'distanceWalked' [cite: 65]

    try {
        const topUsers = await User.find()
            // Hanya ambil data yang relevan untuk leaderboard
            .select('username currentRank greenPoints XP avatarId') 
            .sort({ [sortField]: -1 }) // Urutkan descending (tertinggi di atas)
            .limit(parseInt(limit));

        res.json(topUsers);

    } catch (err) {
        console.error('ERROR FETCHING LEADERBOARD:', err.message);
        res.status(500).json({ msg: 'Server error when fetching leaderboard.' });
    }
});

module.exports = router;