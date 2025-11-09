// Ecoverse-API/routes/api/user_data.js

const express = require('express');
const router = express.Router();
const auth = require('../../middleware/auth'); 
const User = require('../../models/User');
const Achievement = require('../../models/Achievement'); 

// --- Leveling and Reward Constants ---
const BASE_XP = 1000;
const MULTIPLIER = 1.75; 
const WALK_REWARD_INTERVAL = 1000; 
const XP_PER_KM = 20;
const GP_PER_KM = 40;

// Helper function to calculate Leveling Data
function calculateLevelData(xp) {
    let currentLevel = 1;
    let cumulativeXP = 0; 
    let levelXPRequired = BASE_XP; 

    while (xp >= cumulativeXP + levelXPRequired) {
      cumulativeXP += levelXPRequired;
      levelXPRequired *= MULTIPLIER;
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

// @route   GET api/user-data/inventory  
// @desc    Get user's general inventory items and achievements
// @access  Private
router.get('/inventory', auth, async (req, res) => {
    try {
        // Retrieve inventory array and distance for achievement calculation
        const user = await User.findById(req.user.id).select('inventory distanceWalked'); 
        if (!user) {
            return res.status(404).json({ msg: 'User not found.' });
        }
        
        // Fetch ALL achievements defined in the game
        const allAchievements = await Achievement.find();

        // Data needed by the frontend for achievement progress simulation
        const userStatsForAchievements = {
            distanceWalked: user.distanceWalked, 
            total_collected: 500, // Placeholder/Sample data
            events_joined: 3, // Placeholder/Sample data
        };


        res.json({
            generalItems: user.inventory,
            allAchievements: allAchievements,
            userStats: userStatsForAchievements, 
        });

    } catch (err) {
        console.error('ERROR FETCHING INVENTORY/ACHIEVEMENTS:', err.message);
        res.status(500).json({ msg: 'Server error when fetching inventory data.' });
    }
});


// @route   GET api/user-data/summary
router.get('/summary', auth, async (req, res) => {
    try {
        // CRITICAL: Ensure 'diamonds' is selected here
        const user = await User.findById(req.user.id).select('username XP greenPoints currentRank avatarId diamonds'); 
        if (!user) { return res.status(404).json({ msg: 'User not found.' }); }
        const levelData = calculateLevelData(user.XP);
        
        res.json({
            username: user.username, 
            XP: user.XP, 
            GP: user.greenPoints, 
            diamonds: user.diamonds, // <-- FINAL FIX: Send Diamond balance
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
router.get('/full-profile', auth, async (req, res) => {
    try {
        // CRITICAL: Ensure 'diamonds' is selected here
        const user = await User.findById(req.user.id).select('username email XP greenPoints currentRank distanceWalked motto avatarId diamonds'); 
        if (!user) { return res.status(404).json({ msg: 'User not found.' }); }
        const levelData = calculateLevelData(user.XP);
        
        res.json({
            username: user.username, 
            email: user.email, 
            XP: user.XP, 
            GP: user.greenPoints,
            diamonds: user.diamonds, // <-- FINAL FIX: Send Diamond balance
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
router.put('/profile', auth, async (req, res) => {
    const { username, email, motto, avatarId } = req.body; 
    const updateFields = {};
    if (username) updateFields.username = username;
    if (email) updateFields.email = email;
    if (avatarId !== undefined) updateFields.avatarId = avatarId; 
    updateFields.motto = motto === undefined ? '' : motto; 
    
    try {
        let user = await User.findById(req.user.id);
        if (!user) { return res.status(404).json({ msg: 'User not found' }); }
        user = await User.findByIdAndUpdate(
            req.user.id, { $set: updateFields }, { new: true, runValidators: true }
        ).select('-password'); 
        res.json({ msg: 'Profile updated successfully', user });
    } catch (err) {
        console.error('ERROR UPDATING PROFILE:', err.message);
        res.status(500).send('Server Error');
    }
});


// @route   POST api/user-data/update-distance
router.post('/update-distance', auth, async (req, res) => {
    const { distanceDelta } = req.body; 

    if (distanceDelta === undefined || distanceDelta < 0) {
        return res.status(400).json({ msg: 'Invalid distance delta.' });
    }

    try {
        let user = await User.findById(req.user.id).select('XP greenPoints distanceWalked');
        if (!user) return res.status(404).json({ msg: 'User not found.' });

        const oldDistance = user.distanceWalked;
        const distanceDeltaInt = Math.floor(distanceDelta); 
        const oldKilometers = Math.floor(oldDistance / WALK_REWARD_INTERVAL);
        const newKilometers = Math.floor((oldDistance + distanceDeltaInt) / WALK_REWARD_INTERVAL);
        
        const kilometersCompleted = newKilometers - oldKilometers;
        let updateQuery = { $inc: { distanceWalked: distanceDeltaInt } };

        if (kilometersCompleted > 0) {
            const xpEarned = kilometersCompleted * XP_PER_KM;
            const gpEarned = kilometersCompleted * GP_PER_KM;
            
            updateQuery.$inc.XP = xpEarned;
            updateQuery.$inc.greenPoints = gpEarned;

            await User.findByIdAndUpdate(req.user.id, updateQuery);

            return res.json({ 
                msg: `Distance and rewards updated. Gained ${xpEarned} XP and ${gpEarned} GP for walking ${kilometersCompleted} km.`,
                newTotalDistance: oldDistance + distanceDeltaInt
            });
        }
        
        await User.findByIdAndUpdate(req.user.id, updateQuery);

        res.json({ 
            msg: 'Distance updated successfully.',
            newTotalDistance: oldDistance + distanceDeltaInt
        });

    } catch (err) {
        console.error('ERROR UPDATING DISTANCE:', err.message);
        res.status(500).send('Server Error');
    }
});

// @route   POST api/user-data/simulate-topup
router.post('/simulate-topup', auth, async (req, res) => {
    const { amount } = req.body; 

    if (!amount || amount <= 0) {
        return res.status(400).json({ msg: 'Invalid top-up amount.' });
    }

    try {
        // Increment diamonds and return the new balance
        const user = await User.findByIdAndUpdate(
            req.user.id,
            { $inc: { diamonds: amount } }, 
            { new: true }
        ).select('diamonds');

        res.json({ 
            msg: `${amount} Diamonds added successfully (Simulated Top-Up).`,
            newBalance: user.diamonds
        });

    } catch (err) {
        console.error('ERROR SIMULATING TOPUP:', err.message);
        res.status(500).send('Server Error');
    }
});


// @route   POST api/user-data/convert-diamond
router.post('/convert-diamond', auth, async (req, res) => {
    const { amount } = req.body; 
    const GP_RATE = 10; 

    if (!amount || amount <= 0) {
        return res.status(400).json({ msg: 'Invalid conversion amount.' });
    }

    try {
        let user = await User.findById(req.user.id).select('diamonds greenPoints');

        if (!user) return res.status(404).json({ msg: 'User not found.' });
        if (user.diamonds < amount) {
            return res.status(400).json({ msg: 'Insufficient Diamonds.' });
        }
        
        const gpEarned = amount * GP_RATE;

        // Decrease Diamond and increase GP
        await User.findByIdAndUpdate(
            req.user.id,
            { $inc: { diamonds: -amount, greenPoints: gpEarned } }, 
            { new: true }
        );

        res.json({ 
            msg: `Converted ${amount} Diamonds to ${gpEarned} GP.`,
            gpEarned: gpEarned
        });

    } catch (err) {
        console.error('ERROR CONVERTING DIAMOND:', err.message);
        res.status(500).send('Server Error');
    }
});


module.exports = router;