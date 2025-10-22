// Ecoverse-API/config/db.js

const mongoose = require('mongoose');

// GANTI MONGO_URI DENGAN URI ATLAS ANDA + NAMA DATABASE
// Tambahkan nama database "ecoverseDB" di akhir URI Anda.
const MONGO_URI = 'mongodb+srv://drhaikal0_db_user:MV2BNZ2C0RjjInzM@cluster0.7aluxmt.mongodb.net/ecoverseDB?retryWrites=true&w=majority'; 

const connectDB = async () => {
  try {
    // Menghubungkan ke MongoDB
    await mongoose.connect(MONGO_URI);
    
    console.log('MongoDB Connected successfully! (Atlas)');
  } catch (err) {
    console.error(`MongoDB connection error: ${err.message}`);
    // Keluar dari proses jika koneksi gagal
    process.exit(1);
  }
};

module.exports = connectDB;