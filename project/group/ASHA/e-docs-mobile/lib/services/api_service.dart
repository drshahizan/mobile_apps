import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/document.dart';

class ApiService {
  // For Android Emulator: use 'http://10.0.2.2:3000/api'
  // For iOS Simulator or physical device: use 'http://localhost:3000/api' or your PC's IP
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Assuming we're on Android Emulator
  
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  String? getToken() {
    return _token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _getHeaders(includeAuth: false),
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        return {
          'success': true,
          'token': data['token'],
          'user': User.fromJson(data['user']),
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> register(String username, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _getHeaders(includeAuth: false),
        body: jsonEncode({
          'username': username,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'User registered successfully',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  Future<List<Document>> getDocuments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/documents'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Document.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load documents');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  Future<Document> getDocument(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/documents/$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return Document.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load document');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  Future<Map<String, dynamic>> uploadDocument(
    String title,
    String description,
    File file,
    String tags,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/documents'),
      );

      request.headers['Authorization'] = 'Bearer $_token';
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['tags'] = tags;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'document': Document.fromJson(jsonDecode(response.body)),
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Upload failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  Future<String> downloadDocument(int id, String fileName) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/documents/$id/download'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final directory = Directory.systemTemp;
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        throw Exception('Failed to download document');
      }
    } catch (e) {
      throw Exception('Download error: $e');
    }
  }

  Future<bool> deleteDocument(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/documents/$id'),
        headers: _getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> updateDocument(
    int id,
    String title,
    String description,
    String tags,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/documents/$id'),
        headers: _getHeaders(),
        body: jsonEncode({
          'title': title,
          'description': description,
          'tags': tags,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'document': Document.fromJson(jsonDecode(response.body)),
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Update failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  Future<List<User>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  Future<Map<String, dynamic>> createUser(
    String username,
    String password,
    String role,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: _getHeaders(),
        body: jsonEncode({
          'username': username,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'user': User.fromJson(jsonDecode(response.body)),
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'User creation failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateUser(
    int id,
    String? username,
    String? password,
    String? role,
  ) async {
    try {
      final body = <String, dynamic>{};
      if (username != null) body['username'] = username;
      if (password != null) body['password'] = password;
      if (role != null) body['role'] = role;

      final response = await http.put(
        Uri.parse('$baseUrl/users/$id'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': User.fromJson(jsonDecode(response.body)),
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Update failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$id'),
        headers: _getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
