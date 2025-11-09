// Ecoverse-API/routes/api/social.js (Full Code)

const express = require('express');
const router = express.Router();
const auth = require('../../middleware/auth'); 
const User = require('../../models/User');

// --- Helper Functions ---

// @route   GET api/social/search
// @desc    Search users by username
// @access  Private
router.get('/search', auth, async (req, res) => {
    const { query } = req.query;
    if (!query) return res.status(400).json({ msg: 'Search query is required.' });

    try {
        // Cari user yang username-nya mengandung query (case-insensitive)
        const users = await User.find({ 
            username: { $regex: query, $options: 'i' },
            _id: { $ne: req.user.id } // Jangan tampilkan diri sendiri
        }).select('username currentRank avatarId');

        res.json(users);

    } catch (err) {
        console.error('ERROR SEARCHING USERS:', err.message);
        res.status(500).send('Server Error');
    }
});

// @route   POST api/social/request/:targetId
// @desc    Send a friend request
// @access  Private
router.post('/request/:targetId', auth, async (req, res) => {
    const senderId = req.user.id;
    const targetId = req.params.targetId;

    if (senderId === targetId) return res.status(400).json({ msg: 'Cannot add yourself.' });

    try {
        const [sender, target] = await Promise.all([
            User.findById(senderId),
            User.findById(targetId).select('friendRequests friends')
        ]);

        if (!target) return res.status(404).json({ msg: 'Target user not found.' });

        // Cek jika sudah teman
        if (target.friends.includes(senderId)) {
            return res.status(400).json({ msg: 'Already friends.' });
        }
        // Cek jika permintaan sudah dikirim
        if (target.friendRequests.includes(senderId)) {
            return res.status(400).json({ msg: 'Request already sent.' });
        }
        
        // Cek jika target sudah mengirim permintaan, langsung terima
        if (sender.friendRequests.includes(targetId)) {
            // Langsung terima: Menghapus permintaan dari pengirim dan menambah teman di kedua sisi
            await User.findByIdAndUpdate(senderId, { $pull: { friendRequests: targetId }, $push: { friends: targetId } });
            await User.findByIdAndUpdate(targetId, { $push: { friends: senderId } });

            return res.json({ msg: 'Friend request accepted automatically (mutual request).', status: 'accepted' });
        }


        // Tambahkan ID pengirim ke list friendRequests target
        await User.findByIdAndUpdate(targetId, { $push: { friendRequests: senderId } });

        res.json({ msg: 'Friend request sent.', status: 'pending' });

    } catch (err) {
        console.error('ERROR SENDING REQUEST:', err.message);
        res.status(500).send('Server Error');
    }
});

// @route   GET api/social/friends
// @desc    Get the user's friend list
// @access  Private
router.get('/friends', auth, async (req, res) => {
    try {
        const user = await User.findById(req.user.id)
            .select('friends friendRequests')
            .populate('friends', 'username currentRank avatarId XP greenPoints') // Isi detail teman
            .populate('friendRequests', 'username currentRank avatarId'); // Isi detail permintaan

        res.json({
            friends: user.friends,
            requests: user.friendRequests,
        });

    } catch (err) {
        console.error('ERROR FETCHING FRIENDS:', err.message);
        res.status(500).send('Server Error');
    }
});

// @route   POST api/social/accept/:senderId
// @desc    Accept a friend request
// @access  Private
router.post('/accept/:senderId', auth, async (req, res) => {
    const acceptorId = req.user.id;
    const senderId = req.params.senderId;

    try {
        // 1. Hapus permintaan dari list penerima (acceptor) dan tambahkan sebagai teman
        const acceptor = await User.findByIdAndUpdate(
            acceptorId, 
            { $pull: { friendRequests: senderId }, $push: { friends: senderId } }, 
            { new: true }
        );

        // 2. Tambahkan penerima sebagai teman di list pengirim (sender)
        await User.findByIdAndUpdate(senderId, { $push: { friends: acceptorId } });

        res.json({ msg: 'Friend request accepted.', acceptorId });

    } catch (err) {
        console.error('ERROR ACCEPTING REQUEST:', err.message);
        res.status(500).send('Server Error');
    }
});


module.exports = router;