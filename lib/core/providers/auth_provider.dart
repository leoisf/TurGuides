import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  Usuario? _currentUser;
  bool _isLoading = false;

  Usuario? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<void> checkAuthStatus() async {
    _currentUser = await _storage.getUser();
    notifyListeners();
  }

  Future<bool> login(String emailOrDocument, String senha) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.post(
        '${AppConfig.auth}/login',
        {
          'emailOrDocument': emailOrDocument,
          'senha': senha,
        },
      );

      // A API retorna { token, usuario } diretamente, não dentro de 'data'
      if (response['token'] != null) {
        final token = response['token'];
        final userData = response['usuario'];
        
        await _storage.saveToken(token);
        _currentUser = Usuario.fromJson(userData);
        await _storage.saveUser(_currentUser!);
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.post(AppConfig.usuarios, userData);
      
      if (response['success']) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _storage.clearAll();
    _currentUser = null;
    notifyListeners();
  }
}
