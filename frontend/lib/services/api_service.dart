import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class ApiService {
  static const String baseUrl = "http://127.0.0.1:5000"; // change for iOS/real device

  // 🔹 Login API
  static Future<Map<String, dynamic>> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"identifier": username, "password": password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body); // success response
    } else {
      throw Exception(data["error"] ?? "Something went wrong");
    }
  }
  static Future<Map<String,dynamic>> signupUser(String username,String email,String password) async{
    final response = await http.post(
      Uri.parse("$baseUrl/auth/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username,"email":email, "password": password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return jsonDecode(response.body); // success response
    } else {
      throw Exception(data["error"] ?? "Something went wrong");
    }
  }
  static Future<List<dynamic>> getPosts() async{
    final prefs= await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    if (token == null) throw Exception("No token found");
    final response =await http.get(
      Uri.parse("$baseUrl/api/posts"),
      headers:{
        "Authorization": "Bearer $token",
      }
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch posts: ${response.body}");
    }
  }
}
