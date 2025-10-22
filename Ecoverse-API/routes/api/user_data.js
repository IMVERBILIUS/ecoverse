// Ecoverse-API/routes/api/user_data.js

const express = require('express');
const router = express.Router();
const auth = require('../../middleware/auth'); 
const User = require('../../models/User');

// --- Leveling Constants (Harus sama dengan di Flutter) ---
const BASE_XP = 1000;
const MULTIPLIER = 1.75; 

// --- Reward Constants ---
const WALK_REWARD_INTERVAL = 1000; // Reward setiap 1000 meter (1 km)
const XP_PER_KM = 20;
const GP_PER_KM = 40;

// Fungsi Helper untuk menghitung Leveling Data
function calculateLevelData(xp) {
    let currentLevel = 1;
    let cumulativeXP = 0; 
    let levelXPRequired = BASE_XP; 

    while (xp >= cumulativeXP + levelXPRequired) {
      cumulativeXP += levelXPRequired;
      levelXPRequired *= MULTIPLER;
      currentLevel++;
    }

    const xpRequiredThisLevel = Math.floor(levelXPRequired);
    const xpProgress = xp - cumulativeXP;
    
    return {
        level: currentLevel,
        xpProgress: xpProgress,
        xpRequiredThisLevel: xpRequiredThisLevel,
    };
}
// --------------------------------------------------------


// @route   GET api/user-data/summary
// @desc    Get essential user stats for the map/navbar
// @access  Private
router.get('/summary', auth, async (req, res) => {
    try {
        const user = await User.findById(req.user.id).select('username XP greenPoints currentRank avatarId'); 

        if (!user) {
            return res.status(404).json({ msg: 'User not found.' });
        }

        const levelData = calculateLevelData(user.XP);
        
        res.json({
            username: user.username,
            XP: user.XP,
            GP: user.greenPoints,
            rank: user.currentRank,
            avatarId: user.avatarId,
            level: levelData.level,
            progressFraction: levelData.xpProgress / levelData.xpRequiredThisLevel,
            xpProgress: levelData.xpProgress,
            xpRequiredThisLevel: levelData.xpRequiredThisLevel,
        });

    } catch (err) {
        console.error('ERROR FETCHING USER SUMMARY:', err.message);
        res.status(500).json({ msg: 'Server error when fetching user summary.' });
    }
});


// @route   GET api/user-data/full-profile
// @desc    Get all user stats for the Profile Screen
// @access  Private
router.get('/full-profile', auth, async (req, res) => {
    try {
        const user = await User.findById(req.user.id).select('username email XP greenPoints currentRank distanceWalked motto avatarId'); 

        if (!user) {
            return res.status(404).json({ msg: 'User not found.' });
        }

        const levelData = calculateLevelData(user.XP);
        
        res.json({
            username: user.username,
            email: user.email,
            XP: user.XP,
            GP: user.greenPoints,
            rank: user.currentRank,
            distanceWalked: user.distanceWalked,
            motto: user.motto, 
            avatarId: user.avatarId,
            
            level: levelData.level,
            xpProgress: levelData.xpProgress,
            xpRequiredThisLevel: levelData.xpRequiredThisLevel,
            progressFraction: levelData.xpProgress / levelData.xpRequiredThisLevel,
        });

    } catch (err) {
        console.error('ERROR FETCHING FULL PROFILE:', err.message);
        res.status(500).json({ msg: 'Server error when fetching full profile.' });
    }
});


// @route   PUT api/user-data/profile
// @desc    Update user profile data (username, email, motto, avatarId)
// @access  Private
router.put('/profile', auth, async (req, res) => {
    const { username, email, motto, avatarId } = req.body; 
    const updateFields = {};

    if (username) updateFields.username = username;
    if (email) updateFields.email = email;
    if (avatarId !== undefined) updateFields.avatarId = avatarId; 
    updateFields.motto = motto === undefined ? '' : motto; 
    
    try {
        let user = await User.findById(req.user.id);
        if (!user) {
            return res.status(404).json({ msg: 'User not found' });
        }

        user = await User.findByIdAndUpdate(
            req.user.id,
            { $set: updateFields },
            { new: true, runValidators: true }
        ).select('-password'); 

        res.json({ msg: 'Profile updated successfully', user });
    } catch (err) {
        console.error('ERROR UPDATING PROFILE:', err.message);
        res.status(500).send('Server Error');
    }
});


// @route   POST api/user-data/update-distance
// @desc    Update user's total distance walked and award XP/GP if threshold is met
// @access  Private
router.post('/update-distance', auth, async (req, res) => {
    const { distanceDelta } = req.body; // Jarak baru (dalam meter) sejak update terakhir

    if (distanceDelta === undefined || distanceDelta < 0) {
        return res.status(400).json({ msg: 'Invalid distance delta.' });
    }

    try {
        let user = await User.findById(req.user.id).select('XP greenPoints distanceWalked');
        if (!user) return res.status(404).json({ msg: 'User not found.' });

        const oldDistance = user.distanceWalked;
        const distanceDeltaInt = Math.floor(distanceDelta); // Pastikan integer
        const newDistance = oldDistance + distanceDeltaInt;
        
        // --- LOGIKA REWARD WALK QUESTS ---
        const oldKilometers = Math.floor(oldDistance / WALK_REWARD_INTERVAL);
        const newKilometers = Math.floor(newDistance / WALK_REWARD_INTERVAL);
        
        const kilometersCompleted = newKilometers - oldKilometers;
        let updateQuery = { $inc: { distanceWalked: distanceDeltaInt } };

        if (kilometersCompleted > 0) {
            const xpEarned = kilometersCompleted * XP_PER_KM;
            const gpEarned = kilometersCompleted * GP_PER_KM;
            
            // Tambahkan reward ke query update
            updateQuery.$inc.XP = xpEarned;
            updateQuery.$inc.greenPoints = gpEarned;

            await User.findByIdAndUpdate(req.user.id, updateQuery);

            return res.json({ 
                msg: `Distance and rewards updated. Gained ${xpEarned} XP and ${gpEarned} GP for walking ${kilometersCompleted} km.`,
                newTotalDistance: newDistance
            });
        }
        
        // Jika tidak ada reward, hanya update jarak
        await User.findByIdAndUpdate(req.user.id, updateQuery);

        res.json({ 
            msg: 'Distance updated successfully.',
            newTotalDistance: newDistance
        });

    } catch (err) {
        console.error('ERROR UPDATING DISTANCE:', err.message);
        res.status(500).send('Server Error');
    }
});


module.exports = router;