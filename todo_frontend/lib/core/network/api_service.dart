// lib/core/network/api_service.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://mesob-to-do.onrender.com/api/v1';
  final Dio _dio = Dio();

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  // Auth endpoints
  Future<Response> register(String name, String email, String password) async {
    return _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<Response> login(String email, String password) async {
    return _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> getMe() => _dio.get('/auth/me');

  // New: Update user profile (name, email, password)
  Future<Response> updateProfile(Map<String, dynamic> data) =>
      _dio.put('/auth/me', data: data);

  // Task endpoints
  Future<Response> getTasks() => _dio.get('/tasks');
  Future<Response> getTask(String id) => _dio.get('/tasks/$id');
  Future<Response> createTask(Map<String, dynamic> data) =>
      _dio.post('/tasks', data: data);
  Future<Response> updateTask(String id, Map<String, dynamic> data) =>
      _dio.put('/tasks/$id', data: data);
  Future<Response> deleteTask(String id) => _dio.delete('/tasks/$id');
  Future<Response> toggleTaskCompletion(String id, bool completed) =>
      _dio.put('/tasks/$id/toggle', data: {'completed': completed});
}

