import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../common/utils/jwt_helper.dart';
class CommentsSheet extends StatefulWidget {
  final int postId;
  final VoidCallback? onCommentAdded;
  const CommentsSheet({super.key, required this.postId,required this.onCommentAdded});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  late Future<List<dynamic>> _commentsFuture;
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadComments();
  }
  void _loadComments() {
    setState(() {
      _commentsFuture = ApiService.fetchComments(widget.postId);
    });
  }
  Future<void> addComment(String text) async {
    String? token = await JwtHelper.getToken();
    if(token==null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You need to login first")),
      );
      Navigator.pushReplacementNamed(context, "/login");
      return;
    }
    final response = await http.post(
      Uri.parse("http://127.0.0.1:5000/api/posts/${widget.postId}/comments"),
      headers: {"Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"text": text}),

    );
    if (response.statusCode == 201) {
      setState((){
        _loadComments();
        _controller.clear();
      });
      widget.onCommentAdded?.call();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to add comment")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(height: 4, width: 40, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No comments yet"));
                }
                final comments = snapshot.data!;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final c = comments[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          "https://ui-avatars.com/api/?name=${c['username']}",
                        ),
                      ),
                      title: Text(c['username'],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(c['text']),
                      trailing: Text(
                        c['created_at'].toString().split("T").first, // date only
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Add comment input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Add a comment...",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      addComment(_controller.text.trim());
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
