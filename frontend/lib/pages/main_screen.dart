import 'dart:convert';

import 'package:flutter/material.dart';
import 'home_page.dart';
import 'createNewPost.dart';
import '../common/utils/jwt_helper.dart';
import 'profile.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late String? username,token;
  int _currentIndex = 0;
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
  void initState(){
    super.initState();
    _loadUserFromToken();
  }
  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages=[
      HomePage(key: UniqueKey(),),
      CreatePostPage(
        onPostCreated: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      const SearchPage(),
      ProfilePage(username: username??""),
    ];
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // change page
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: "Create post"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// Dummy pages for now
// class HomePage extends StatelessWidget {
//   const HomePage({super.key});
//   @override
//   Widget build(BuildContext context) => const Center(child: Text("Home Page"));
// }


class SearchPage extends StatelessWidget {
  const SearchPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text("Search Page"));
}