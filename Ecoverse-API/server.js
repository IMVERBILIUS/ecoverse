// Ecoverse-API/server.js

const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db'); // Import fungsi koneksi DB

// PENTING: Import semua Model untuk memastikan skema dikompilasi oleh Mongoose
require('./models/User'); 
require('./models/Quest');
require('./models/EcoSpot'); 
require('./models/PlantPet');
require('./models/CommunityEvent');
require('./models/Achievement'); // Tambahkan Model Achievement
require('./models/Item'); // Tambahkan Model Item

// Inisialisasi Express App
const app = express();

// 1. KONEKSI DATABASE
connectDB();

// 2. MIDDLEWARE UMUM
// Mengizinkan permintaan (request) dari Frontend (Flutter)
app.use(cors()); 
// Mengizinkan server menerima data JSON
app.use(express.json()); 
app.use(express.urlencoded({ extended: false }));

// Melayani file statis (misalnya foto profil dari folder 'uploads')
app.use('/uploads', express.static('uploads')); 

// 3. DEFINISI ROUTE DASAR (Test Route)
app.get('/', (req, res) => res.send('Ecoverse API is Running!'));


// 4. DEFINISI ROUTE UTAMA (API Endpoints)
// Auth & User Management
app.use('/api/users', require('./routes/api/users'));
app.use('/api/user-data', require('./routes/api/user_data'));

// Core Gameplay & Eco-Actions
app.use('/api/ecospots', require('./routes/api/ecospots'));
app.use('/api/missions', require('./routes/api/missions'));
app.use('/api/quests', require('./routes/api/quests')); 
app.use('/api/pets', require('./routes/api/pets'));
app.use('/api/shop', require('./routes/api/shop')); // Route Shop/Item

// Social & Community
app.use('/api/events', require('./routes/api/events'));
app.use('/api/leaderboards', require('./routes/api/leaderboards')); // Route Leaderboard
app.use('/api/social', require('./routes/api/social'));


// 5. MEMULAI SERVER
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => console.log(`Server started on port ${PORT}`));