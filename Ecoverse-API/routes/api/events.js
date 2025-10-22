// Ecoverse-API/routes/api/events.js (Full Code - Final)

const express = require('express');
const router = express.Router();
const auth = require('../../middleware/auth'); 
const CommunityEvent = require('../../models/CommunityEvent');
const User = require('../../models/User');

// @route   GET api/events/upcoming
// @desc    Get all upcoming community events
// @access  Private
router.get('/upcoming', auth, async (req, res) => {
    try {
        const today = new Date();
        const events = await CommunityEvent.find({ eventDate: { $gte: today } }).sort({ eventDate: 1 });

        res.json(events);

    } catch (err) {
        console.error('ERROR FETCHING EVENTS:', err.message);
        res.status(500).json({ msg: 'Server error when fetching events.' });
    }
});


// @route   POST api/events/join/:eventId
// @desc    User joins a specific event
// @access  Private
router.post('/join/:eventId', auth, async (req, res) => {
    try {
        const eventId = req.params.eventId;
        const userId = req.user.id;

        const event = await CommunityEvent.findById(eventId);
        if (!event) {
            return res.status(404).json({ msg: 'Event not found.' });
        }
        
        if (event.participants.includes(userId)) {
            return res.status(400).json({ msg: 'You are already registered for this event.' });
        }

        if (event.participants.length >= event.maxParticipants) {
             return res.status(400).json({ msg: 'Event is full!' });
        }

        event.participants.push(userId);
        await event.save();

        res.json({ msg: 'Successfully joined event!', event: event });

    } catch (err) {
        console.error('ERROR JOINING EVENT:', err.message);
        res.status(500).json({ msg: 'Server error during event join.' });
    }
});


// @route   POST api/events/cancel-join/:eventId
// @desc    User cancels registration for an event
// @access  Private
router.post('/cancel-join/:eventId', auth, async (req, res) => {
    try {
        const eventId = req.params.eventId;
        const userId = req.user.id;

        const event = await CommunityEvent.findById(eventId);
        if (!event) {
            return res.status(404).json({ msg: 'Event not found.' });
        }
        
        // Cek apakah user memang terdaftar
        if (!event.participants.includes(userId)) {
            return res.status(400).json({ msg: 'You are not currently registered for this event.' });
        }

        // Hapus user dari list participants
        event.participants.pull(userId); // Menggunakan mongoose pull
        await event.save();

        res.json({ msg: 'Successfully cancelled registration.', event: event });

    } catch (err) {
        console.error('ERROR CANCELLING JOIN:', err.message);
        res.status(500).json({ msg: 'Server error during cancellation.' });
    }
});


module.exports = router;