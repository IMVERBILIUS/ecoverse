// Ecoverse-API/server.js

const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db'); // Import fungsi koneksi DB

// PENTING: Import model untuk memastikan skema dikompilasi oleh Mongoose
require('./models/Quest'); // <-- TAMBAHKAN INI UNTUK MODEL QUEST
require('./models/User'); // Pastikan model penting lainnya juga di-import di sini
require('./models/EcoSpot'); 
require('./models/PlantPet');
require('./models/CommunityEvent');


// Inisialisasi Express App
const app = express();

// 1. KONEKSI DATABASE
connectDB();

// 2. MIDDLEWARE
// Mengizinkan Flutter (Frontend) mengakses API
app.use(cors()); 
// Mengizinkan server menerima data JSON
app.use(express.json()); 
app.use(express.urlencoded({ extended: false }));

// 3. DEFINISI ROUTE DASAR (Test Route)
app.get('/', (req, res) => res.send('Ecoverse API is Running!'));

// 4. DEFINISI ROUTE UTAMA
app.use('/api/users', require('./routes/api/users'));
app.use('/api/ecospots', require('./routes/api/ecospots'));
app.use('/api/missions', require('./routes/api/missions'));
app.use('/api/quests', require('./routes/api/quests')); // <-- PASTIKAN ROUTE BARU JUGA ADA
app.use('/api/pets', require('./routes/api/pets'));
app.use('/api/events', require('./routes/api/events'));
app.use('/api/user-data', require('./routes/api/user_data'));
app.use('/uploads', express.static('uploads'));
app.use('/api/leaderboards', require('./routes/api/leaderboards'));
// 5. MEMULAI SERVER
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => console.log(`Server started on port ${PORT}`));