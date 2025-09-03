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
  final ScrollController _scrollController = ScrollController();
  int currPage=1;
  int per_page=2;
  bool hasNext=true;
  String? username;
  String? token;
  bool isLoading=false;
  final List<Post> listingPosts = [
  ];
  @override
  void initState(){
    super.initState();
    _loadUserFromToken();
    _loadPostsFromApi();
    _scrollController.addListener((){
      if(_scrollController.position.pixels>=_scrollController.position.maxScrollExtent-200&&!isLoading){
        _loadPostsFromApi();
      }

    });
  }
  Future<void> _loadPostsFromApi() async{
    if(!hasNext) return;
    setState(() => isLoading = true);
    try{
      final data=await ApiService.getPosts(currPage,per_page);
      final pagePosts=data["posts"] as List;
      final fetchedPosts=pagePosts.map<Post>((json)=>Post.fromJson(json)).toList();
      setState(() {
        listingPosts.addAll(fetchedPosts);
        isLoading=false;
        final meta=data["meta"];
        hasNext=meta["has_next"];
        if(hasNext) currPage++;
      });
    }
    catch(e){
      print(e);
      setState(() {
        isLoading=false;
      });
    }
  }
  Future<void> _loadUserFromToken() async{
    String? savedToken = await JwtHelper.getToken();
    if(savedToken!=null){
      Map<String, dynamic>? decodedToken = await JwtHelper.decodeToken();
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
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        controller: _scrollController,
          itemCount: listingPosts.length+2,
        itemBuilder: (context,index){
          if(index==0){
            return const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "Recent posts",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            );
          }
          else if(index==listingPosts.length+1){
            return hasNext
                ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            )
                : const SizedBox.shrink();
          }
          else{
            final p = listingPosts[index - 1];
            return PostCard(
              post: p,
              token: token,
              onPostChanged: () {
                setState(() {
                  final i = listingPosts.indexWhere((post) => post.id == p.id);
                  if (i != -1) listingPosts[i] = p;
                });
              },
              onPostDelete: () {
                setState(() {
                  listingPosts.removeWhere((post) => post.id == p.id);
                });
              },
            );
          }
        },
      ),
    );
  }
}
