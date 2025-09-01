import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class ApiService {
  static const String baseUrl = "http://127.0.0.1:5000"; // change for iOS/real device

  // 🔹 Login API
  static Future<Map<String, dynamic>> loginUser(String username,
      String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"identifier": username, "password": password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(data["error"] ?? "Something went wrong");
    }
  }

  static Future<Map<String, dynamic>> signupUser(String username, String email,
      String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
          {"username": username, "email": email, "password": password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return jsonDecode(response.body); // success response
    } else {
      throw Exception(data["error"] ?? "Something went wrong");
    }
  }

  static Future<List<dynamic>> getPosts() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    if (token == null) throw Exception("No token found");
    final response = await http.get(
        Uri.parse("$baseUrl/api/posts"),
        headers: {
          "Authorization": "Bearer $token",
        }
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch posts: ${response.body}");
    }
  }

  static Future<void> clickLiked(String postId, String token) async {
    final url = Uri.parse("$baseUrl/api/like/$postId");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to toggle like: ${response.body}");
    }
  }

  static Future<http.StreamedResponse> createPost({
    required String title,
    required String content,
    required File imageFile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final uri = Uri.parse("$baseUrl/api/posts");
    var request = http.MultipartRequest("POST", uri)
      ..headers["Authorization"] = "Bearer $token"
      ..fields["title"] = title
      ..fields["content"] = content
      ..files.add(await http.MultipartFile.fromPath("file", imageFile.path));
    return await request.send();
  }

  static Future<http.Response> updatePost({
    required int postId,
    required String title,
    required String content,
    File? imageFile,
  }) async {
    var url = Uri.parse("$baseUrl/api/posts/$postId");
    var request = http.MultipartRequest("PUT", url);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    request.headers["Authorization"] = "Bearer $token";
    request.fields["title"] = title;
    request.fields["content"] = content;

    if (imageFile != null) {
      request.files.add(
          await http.MultipartFile.fromPath("image", imageFile.path));
    }
    var streamed = await request.send();
    return await http.Response.fromStream(streamed);
  }

  static Future<List<dynamic>> fetchComments(int postId) async {
    final response = await http
        .get(Uri.parse("http://127.0.0.1:5000/api/posts/${postId}/comments"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load comments");
    }
  }

  static Future<bool> deletePost(int postId, String token) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/api/posts/$postId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200;
  }
}
