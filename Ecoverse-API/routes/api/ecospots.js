const express = require('express');
const router = express.Router();
const EcoSpot = require('../../models/EcoSpot'); // Import model EcoSpot
// Catatan: EcoSpots bisa diakses publik, tapi biasanya kita tambahkan auth middleware 
// untuk aplikasi game agar hanya user terdaftar yang bisa mengakses.

// @route   GET api/ecospots/nearby
// @desc    Get EcoSpots near the user's location
// @access  Public (or Private after auth is implemented)
router.get('/nearby', async (req, res) => {
    // Di aplikasi sungguhan, kita akan menggunakan query string: 
    // const { lat, lng, maxDistance } = req.query; 
    // Untuk MVP, kita ambil semua EcoSpots untuk pengujian
    
    try {
        // Ambil semua EcoSpots dari database
        const spots = await EcoSpot.find({});

        // Jika tidak ada data, Anda dapat menambahkan data awal secara manual ke MongoDB untuk pengujian.
        if (spots.length === 0) {
            // Contoh data dummy jika DB kosong (HANYA UNTUK TEST)
            const dummySpot = new EcoSpot({
                name: 'Main Park Recycling Point',
                type: 'Recycling Station',
                location: {
                    type: 'Point',
                    coordinates: [106.8456, -6.2088] // [Lng, Lat] - Lokasi Jakarta
                },
                materialAccepted: ['Plastic', 'Paper'],
                currentStatus: 'Empty'
            });
            await dummySpot.save();
            return res.json([dummySpot]);
        }

        res.json(spots);
    } catch (err) {
        console.error(err.message);
        res.status(500).send('Server error');
    }
});

module.exports = router;