class AppConfig {
  // Use 10.0.2.2 for Android Emulator (maps to host's localhost)
  // For physical device, replace with your computer's IP (e.g., 192.168.1.100)
  static const String baseUrl = 'http://10.0.2.2:3001/api';
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
}
