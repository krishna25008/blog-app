import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
class PostCard extends StatefulWidget {
  final Post post;
  final String? token;
  const PostCard({super.key, required this.post,required this.token});
  @override
  State<PostCard> createState() => _PostCardState();
}
class _PostCardState extends State<PostCard> {
  bool _isLoading = false;

  Future<void> clickLike() async{
    if(_isLoading) return;
    setState(() {
      _isLoading = true;
      if (widget.post.isLiked) {
        widget.post.isLiked = false;
        widget.post.likes -= 1;
      } else {
        widget.post.isLiked = true;
        widget.post.likes += 1;
      }
    });
    try{
      await ApiService.clickLiked(widget.post.id, widget.token??" ");
    }
    catch(e){
      setState(() {
        if (widget.post.isLiked) {
          widget.post.isLiked = false;
          widget.post.likes -= 1;
        } else {
          widget.post.isLiked = true;
          widget.post.likes += 1;
        }
      });
      print("Like error: $e");
    }
    finally{
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.post.userImage),
            ),
            title: Text(widget.post.username,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(widget.post.date),
            trailing: const Icon(Icons.more_vert),
          ),

          // Post Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: widget.post.postImage,        // your post image URL
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,                          // same height as your image
                width: double.infinity,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(), // loading spinner
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          // Like n Comment Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      clickLike();
                    });
                  },
                ),
                Text("${widget.post.likes}"),
                const SizedBox(width: 16),
                const Icon(Icons.comment_outlined),
                const SizedBox(width: 4),
                Text("${widget.post.comments} comments"),
              ],
            ),
          ),

          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(widget.post.caption),
          ),
        ],
      ),
    );
  }
}
