import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:submission_flutter_4/model/story.dart';
import 'package:submission_flutter_4/model/user.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  final String stateKey = "state";
  final String userKey = "user";
  static const baseUrl = 'https://story-api.dicoding.dev/v1';
  static const tokenKey = 'token';

  String? token;

  Future<Map<String, dynamic>> register(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': user.name,
        'email': user.email,
        'password': user.password,
      }),
    );

    print('Register response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 201) {
      return {'success': true};
    } else {
      final responseData = jsonDecode(response.body);
      return {'success': false, 'message': responseData['message']};
    }
  }

  Future<List<Story>> getStories(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stories'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['listStory'];
      List<Story> stories = data.map((json) => Story.fromJson(json)).toList();
      return stories;
    } else {
      throw Exception('Failed to load stories');
    }
  }

  Future<bool> isLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    return preferences.getBool(stateKey) ?? false;
  }

  Future<Map<String, dynamic>> login(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': user.email,
        'password': user.password,
      }),
    );

    print('Login response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['loginResult']['token'];

      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('token', token!);

      return {'success': true, 'token': token};
    } else {
      final responseData = jsonDecode(response.body);
      return {'success': false, 'message': responseData['message']};
    }
  }

  Future<bool> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(tokenKey);
    await preferences.setBool(stateKey, false);
    token = null;
    return true;
  }

  Future<bool> saveUser(User user) async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    return preferences.setString(userKey, user.toJson());
  }

  Future<bool> deleteUser() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    return preferences.setString(userKey, "");
  }

  Future<User?> getUser() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    final json = preferences.getString(userKey) ?? "";
    User? user;
    try {
      user = User.fromJson(json);
    } catch (e) {
      user = null;
    }
    return user;
  }

  Future<String?> getToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(tokenKey);
  }
}
