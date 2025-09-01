import 'dart:ffi';

class Post {
  final String id;
  final String username;
  final String date;
   String title;
   String userImage;
   String postImage;
   String content;
  bool isLiked;
  int likes;
  int comments;

  Post({
    required this.id,
    required this.username,
    required this.date,
    required this.title,
    required this.userImage,
    required this.postImage,
    required this.content,
    required this.isLiked,
    this.likes =0,
    this.comments = 0,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json["id"].toString(),
      username: json["username"],
      date: json["date"],
      userImage: json["userImage"]?? "https://picsum.photos/200",
      postImage: json["postImage"],
      content: json["content"],
      isLiked: json["is_liked"],
      likes: json["likes"],
      title:json["title"],
      comments: json["comments"],
    );
  }
}