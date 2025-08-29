import 'package:flutter/material.dart';
import '../common/utils/jwt_helper.dart';
import 'postCard.dart';
import '../models/post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  String? username;
  String? token;
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
    String? savedToken = await JwtHelper.getToken();
    if(savedToken!=null){
      Map<String, dynamic>? decodedToken = JwtHelper.decodeToken(savedToken);
      print(decodedToken);
      if(decodedToken==null){
        throw Exception("no token found");
      }
      dynamic sub=decodedToken["sub"];

      if (sub is String) {
        sub = jsonDecode(sub.replaceAll("'", '"'));
      }
      setState(() {
        token=savedToken;
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
          ...posts.map((p) => PostCard(post: p,token:token)).toList(),
        ],
      ),
    );
  }
}
