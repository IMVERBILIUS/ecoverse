// lib/services/api_service.dart

class ApiService {
  // GANTI INI: Hanya BASE URL IP dan PORT (Tanpa '/api')
  static const String baseUrl = 'http://192.168.1.11:5000'; 
  
  // Endpoint utama yang akan digunakan untuk semua API calls (misalnya, untuk Mission Service)
  // Mission Service memerlukan ini:
  static const String baseApiUrl = '$baseUrl/api'; 

  // Endpoint Login dan Register
  static String get registerUrl => '$baseApiUrl/users/register'; // Hasil: http://192.168.1.8:5000/api/users/register
  static String get loginUrl => '$baseApiUrl/users/login';       // Hasil: http://192.168.1.8:5000/api/users/login
  
  static String get mapEcoSpotsUrl => '$baseApiUrl/ecospots'; 
}