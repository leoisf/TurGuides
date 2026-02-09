class AppConfig {
  // Using localhost with adb reverse
  // Run: adb reverse tcp:3001 tcp:3001
  static const String baseUrl = 'http://localhost:3001/api';
  static const String healthEndpoint = '/health';
  
  // Endpoints
  static const String usuarios = '/usuarios';
  static const String auth = '/auth';
  static const String atrativos = '/atrativos';
  static const String roteiros = '/roteiros';
  static const String agendamentos = '/agendamentos';
  static const String disponibilidades = '/disponibilidades';
  static const String tiposAtrativos = '/tipos-atrativos';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // Google Maps API Key (mesma chave do sistema web)
  static const String googleMapsApiKey = 'AIzaSyAnTSpYvHhtyIR_IzAY68aGWfqxan6Sz20';
}
