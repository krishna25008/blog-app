import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'postCard.dart';
import '../models/post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'dart:convert';
import '../services/api_service.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;
  final List<Post> posts = [
  ];
  @override
  void initState(){
    super.initState();
    _loadUserFromToken();
    _loadPostsFromApi();
  }
  Future<void> _loadPostsFromApi() async{
    try{
      final data=await ApiService.getPosts();
      final fetchedPosts=data.map<Post>((json)=>Post.fromJson(json)).toList();
      print(fetchedPosts);
      setState(() {
        posts.clear();
        posts.addAll(fetchedPosts);
      });
    }
    catch(e){
      print(e);
    }
  }
  Future<void> _loadUserFromToken() async{
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    if(token!=null){
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      print(decodedToken);
      dynamic sub=decodedToken["sub"];

      if (sub is String) {
        sub = jsonDecode(sub.replaceAll("'", '"'));
      }
      setState(() {
        username = decodedToken["username"];
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text("Hi,${username ??"User"}!"),
        actions: const [
          Icon(Icons.notifications_none),
          SizedBox(width: 12),
        ],
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text("Recent posts",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          ...posts.map((p) => PostCard(post: p)).toList(),
        ],
      ),
    );
  }
}
