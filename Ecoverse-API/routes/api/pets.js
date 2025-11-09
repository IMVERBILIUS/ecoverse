// Ecoverse-API/routes/api/pets.js (Full Code)

const express = require('express');
const router = express.Router();
const auth = require('../../middleware/auth'); 
const User = require('../../models/User');
const PlantPet = require('../../models/PlantPet'); 

// @route   GET api/pets/my-pet
// @desc    Get the user's ACTIVE Plant Pet data and user stats
// @access  Private
router.get('/my-pet', auth, async (req, res) => {
    try {
        // Ambil data user termasuk XP dan distanceWalked
        const user = await User.findById(req.user.id).select('distanceWalked plantPets XP greenPoints currentRank');

        if (!user) {
            return res.status(404).json({ msg: 'User not found.' });
        }
        
        // FIX: Find the pet explicitly marked as active
        const pet = await PlantPet.findOne({ ownerId: user._id, isActive: true });
        
        if (!pet) {
            return res.json({
                userXP: user.XP, userGP: user.greenPoints, userRank: user.currentRank, userDistance: user.distanceWalked,
                pet: null
            });
        }
        
        res.json({
            pet: pet,
            userDistance: user.distanceWalked,
            userRank: user.currentRank,
            userXP: user.XP,
            userGP: user.greenPoints,
        });

    } catch (err) {
        console.error('ERROR FETCHING ACTIVE PET:', err.message);
        res.status(500).json({ msg: 'Server error when fetching active pet data.' });
    }
});

// @route   GET api/pets/inventory
// @desc    Get ALL Plant Pets owned by the user
// @access  Private
router.get('/inventory', auth, async (req, res) => {
    try {
        const userId = req.user.id;
        
        const inventory = await PlantPet.find({ ownerId: userId });

        res.json(inventory);

    } catch (err) {
        console.error('ERROR FETCHING INVENTORY:', err.message);
        res.status(500).json({ msg: 'Server error when fetching inventory.' });
    }
});


// @route   POST api/pets/set-active
// @desc    Change the user's active pet (ensuring only one is active)
// @access  Private
router.post('/set-active', auth, async (req, res) => {
    const { petId } = req.body;

    if (!petId) {
        return res.status(400).json({ msg: 'Pet ID is required.' });
    }

    try {
        const userId = req.user.id;

        // 1. NON-AKTIFKAN semua pet yang dimiliki user
        await PlantPet.updateMany(
            { ownerId: userId, isActive: true },
            { $set: { isActive: false } }
        );

        // 2. AKTIFKAN pet yang diminta
        const newActivePet = await PlantPet.findOneAndUpdate(
            { _id: petId, ownerId: userId },
            { $set: { isActive: true } },
            { new: true }
        );

        if (!newActivePet) {
            return res.status(404).json({ msg: 'Pet not found or does not belong to user.' });
        }

        // 3. Update daftar pet di User model (Pastikan pet aktif ada di indeks 0)
        await User.findByIdAndUpdate(
            userId,
            { $pull: { plantPets: newActivePet._id } }
        );
        await User.findByIdAndUpdate(
            userId,
            { $unshift: { plantPets: newActivePet._id } }
        );


        res.json({ 
            msg: `Successfully set ${newActivePet.name} as active pet.`,
            activePet: newActivePet 
        });

    } catch (err) {
        console.error('ERROR SETTING ACTIVE PET:', err.message);
        res.status(500).json({ msg: 'Server error during pet activation.' });
    }
});


// @route   POST api/pets/evolve/:petId  <-- ROUTE BARU: EVOLVE PET
// @desc    Handle pet evolution/growth stage completion
// @access  Private
router.post('/evolve/:petId', auth, async (req, res) => {
    const petId = req.params.petId;
    const userId = req.user.id;

    try {
        // 1. Ambil Pet dan User Stats
        const [pet, user] = await Promise.all([
            PlantPet.findById(petId),
            User.findById(userId).select('distanceWalked')
        ]);

        if (!pet || !user) {
            return res.status(404).json({ msg: 'Pet or User not found.' });
        }
        if (pet.ownerId.toString() !== userId) {
            return res.status(403).json({ msg: 'Forbidden: Pet does not belong to user.' });
        }

        // 2. Cek Kondisi Evolusi (Growth Progress)
        const currentDistance = user.distanceWalked;
        const requiredDistance = pet.distanceRequired;

        if (currentDistance < requiredDistance) {
            return res.status(400).json({ msg: `Growth incomplete. Needs ${requiredDistance - currentDistance}m more to evolve.` });
        }

        // 3. Eksekusi Evolusi
        const nextDistanceRequired = Math.floor(requiredDistance * 1.5); // Naikkan jarak yang dibutuhkan 50%
        const newStage = pet.growthStage + 1;
        
        // Update Plant Pet: Naikkan stage dan set required distance baru
        await PlantPet.findByIdAndUpdate(
            petId,
            { 
                $inc: { growthStage: 1 },
                distanceRequired: nextDistanceRequired,
                $set: { isActive: true } // Pastikan tetap aktif setelah evolusi
            }
        );
        
        // Update User: Kurangi jarak yang sudah dipakai
        await User.findByIdAndUpdate(
            userId,
            { $inc: { distanceWalked: -requiredDistance } }
        );


        res.json({ 
            msg: `${pet.name} evolved to Stage ${newStage}!`,
            newStage: newStage
        });

    } catch (err) {
        console.error('ERROR EVOLVING PET:', err.message);
        res.status(500).json({ msg: 'Evolution failed due to server error.' });
    }
});


module.exports = router;