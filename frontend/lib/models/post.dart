import 'dart:ffi';

class Post {
  final String id;
  final String username;
  final String date;
  final String userImage;
  final String postImage;
  final String caption;
  bool isLiked;
  int likes;
  int comments;

  Post({
    required this.id,
    required this.username,
    required this.date,
    required this.userImage,
    required this.postImage,
    required this.caption,
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
      caption: json["caption"],
      isLiked: json["is_liked"],
      likes: json["likes"],
      comments: json["comments"],
    );
  }
}