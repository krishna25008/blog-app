import 'package:http/http.dart' as http;
class PostService {
  Future<bool> deletePost(int postId) async {
    final response = await http.delete(
      Uri.parse("https://your-api.com/posts/$postId"),
      headers: {"Authorization": "Bearer <token>"},
    );
    return response.statusCode == 200;
  }
}
