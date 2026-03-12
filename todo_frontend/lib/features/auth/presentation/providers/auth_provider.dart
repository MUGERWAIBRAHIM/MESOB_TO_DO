import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/core/network/api_service.dart';
import 'package:todo_app/features/auth/domain/entities/app_user.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _userId;
  bool _isLoading = false;
  String? _error;
  
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  bool get isAuth => _token != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get token => _token;
  String? get userId => _userId;

  final SharedPreferences prefs;
  
  AuthProvider(this.prefs) {
    init();
  }

  // Initialize auth state
  Future<void> init() async {
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    notifyListeners();
  }

  // Login
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService().login(email, password);
      _token = response.data['token'];
      
      // Store token in SharedPreferences
      await prefs.setString('token', _token!);
      
      // Fetch user info
      await _fetchUserInfo();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // Register
  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService().register(name, email, password);
      _token = response.data['token'];
      
      // Store token in SharedPreferences
      await prefs.setString('token', _token!);
      
      // Fetch user info
      await _fetchUserInfo();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Fetch user info from /me endpoint
  Future<void> _fetchUserInfo() async {
    try {
      final response = await ApiService().getMe();
      final userJson = response.data['data'];

      _currentUser = AppUser.fromJson(userJson);
      _userId = _currentUser!.id;

      await prefs.setString('userId', _userId!);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user info: $e');
    }
  }
  
  // Inside AuthProvider
  Future<void> updateProfile({String? name, String? email, String? password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService().updateProfile({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (password != null) 'password': password,
      });

    // Optionally, update local storage with new data
      await _fetchUserInfo();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }


  // Logout
  Future<void> logout() async {
    await prefs.remove('token');
    await prefs.remove('userId');

    _token = null;
    _userId = null;
    _currentUser = null;

    notifyListeners();
  }


  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

