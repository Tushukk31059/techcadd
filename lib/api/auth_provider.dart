// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:techcadd/api/api_service.dart';


class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get user => _user;

  // Login method
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await ApiService.adminLogin(username, password);
      
      if (response.isNotEmpty) {
        _user = response['user'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    await ApiService.adminLogout();
    _user = null;
    _errorMessage = '';
    notifyListeners();
  }

  // Check if user is logged in
  Future<bool> checkAuthStatus() async {
    try {
      final response = await ApiService.verifyAdminToken();
      if (response['valid'] == true) {
        _user = response['user'];
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}