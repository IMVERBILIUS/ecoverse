// Ecoverse-API/routes/api/quests.js

const express = require('express');
const router = express.Router();
const auth = require('../../middleware/auth'); 
const Quest = require('../../models/Quest');

// @route   GET api/quests/active
// @desc    Get all currently active daily/weekly quests
// @access  Private
router.get('/active', auth, async (req, res) => {
    try {
        // Find all active quests
        const quests = await Quest.find({ isActive: true });

        // In a real application, you would merge this data with the user's progress 
        // before sending it to the app. For MVP, we send the base quest data.
        res.json(quests);

    } catch (err) {
        console.error(err.message);
        res.status(500).json({ msg: 'Server error when fetching quests.' });
    }
});

module.exports = router;