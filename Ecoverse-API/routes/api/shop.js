// Ecoverse-API/routes/api/shop.js (Full Code - Final Purchase Logic)

const express = require('express');
const router = express.Router();
const auth = require('../../middleware/auth');
const Item = require('../../models/Item'); 
const User = require('../../models/User'); // Import User model

// @route   GET api/shop/items
// @desc    Get all items available in the Eco-Shop
// @access  Public
router.get('/items', async (req, res) => {
    try {
        const items = await Item.find().select('-effect');
        res.json(items);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server Error');
    }
});

// @route   POST api/shop/buy/:itemId
// @desc    Handle purchase of an item (Check GP, Subtract cost, Add item)
// @access  Private
router.post('/buy/:itemId', auth, async (req, res) => {
    const itemId = req.params.itemId;
    const userId = req.user.id;
    
    try {
        // 1. Find the Item and the User in one transaction
        const [item, user] = await Promise.all([
            Item.findById(itemId),
            User.findById(userId).select('greenPoints inventory')
        ]);
        
        if (!item) {
            return res.status(404).json({ msg: 'Item not found.' });
        }
        if (!user) {
            return res.status(404).json({ msg: 'User not found.' });
        }
        
        const cost = item.costGP;
        
        // 2. Check Green Point (GP) Balance
        if (user.greenPoints < cost) {
            return res.status(400).json({ msg: `Insufficient Green Points. Required: ${cost} GP.` });
        }
        
        // 3. Execute Purchase
        // Subtract GP and add item name to inventory array
        await User.findByIdAndUpdate(
            userId,
            { 
                $inc: { greenPoints: -cost }, // Subtract cost
                $push: { inventory: item.name } // Add item (using name for simplicity)
            }
        );
        
        res.json({ 
            msg: `Successfully purchased ${item.name}!`,
            item: item.name,
            cost: cost
        });
        
    } catch (err) {
        console.error('ERROR PURCHASING ITEM:', err.message);
        res.status(500).json({ msg: 'Transaction failed due to server error.' });
    }
});

module.exports = router;