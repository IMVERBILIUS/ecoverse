const mongoose = require('mongoose');

// Skema untuk menyimpan koordinat GPS
const GeoSchema = new mongoose.Schema({
    type: {
        type: String,
        default: "Point"
    },
    coordinates: {
        type: [Number], // [Longitude, Latitude]
        index: '2dsphere' // Indeks penting untuk query berbasis lokasi
    }
});

const EcoSpotSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    type: {
        type: String,
        enum: ['Trash Bin', 'Recycling Station', 'Litter Hotspot'],
        required: true
    },
    location: GeoSchema, // Menggunakan skema GeoJSON
    materialAccepted: {
        type: [String],
        default: ['Mixed']
    },
    currentStatus: { // Status bin (misalnya untuk IoT/Litter Hotspot)
        type: String,
        enum: ['Empty', 'Needs Cleaning', 'Full'],
        default: 'Needs Cleaning'
    }
});

module.exports = mongoose.model('EcoSpot', EcoSpotSchema);