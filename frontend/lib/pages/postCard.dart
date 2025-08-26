import 'package:flutter/material.dart';
import '../models/post.dart';

class PostCard extends StatefulWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLiked = false;
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
            child: Image.network(widget.post.postImage, fit: BoxFit.cover),
          ),

          // Like n Comment Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      isLiked = !isLiked;
                      widget.post.likes += isLiked ? 1 : -1;
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
