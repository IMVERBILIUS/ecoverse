// Ecoverse-API/middleware/auth.js
const jwt = require('jsonwebtoken');

module.exports = function(req, res, next) {
    // PENTING: GANTI INI DENGAN KUNCI RAHASIA ANDA!
    const JWT_SECRET = 'supersecretkeyforEcoverse2025'; 

    // 1. Dapatkan token dari header 'x-auth-token'
    const token = req.header('x-auth-token');

    // 2. Cek jika tidak ada token
    if (!token) {
        // Log ini akan muncul jika user mencoba mengakses misi tanpa login
        console.log('Auth Failed: No token provided.');
        return res.status(401).json({ msg: 'No token, authorization denied' });
    }

    // 3. Verifikasi token
    try {
        const decoded = jwt.verify(token, JWT_SECRET); 
        
        // Tambahkan user dari token ke objek request
        req.user = decoded.user;
        next(); // Lanjutkan ke route handler
    } catch (err) {
        // Log ini akan muncul jika token expired atau secret key berbeda
        console.error('Auth Failed: Token is invalid.', err.message);
        res.status(401).json({ msg: 'Token is not valid' });
    }
};