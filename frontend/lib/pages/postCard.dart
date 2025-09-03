import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'EditPost.dart';
import '../common/utils/jwt_helper.dart';
import 'CommentsSheet.dart';
class PostCard extends StatefulWidget {
  final Post post;
  final String? token;
  final VoidCallback? onPostChanged;
  final VoidCallback? onPostDelete;
  const PostCard({super.key, required this.post,required this.token, required  this.onPostChanged,required this.onPostDelete});
  @override
  State<PostCard> createState() => _PostCardState();
}
class _PostCardState extends State<PostCard> {

  void hidePost() {
    print("Hide post logic here");
  }

  Future<void> showDeleteConfirmationDialog(
      BuildContext context,
      VoidCallback onConfirm,
      ) async {
    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(

                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.error, color: Colors.red, size: 40),
                ),
                SizedBox(height: 16),
                Text(
                  "Delete this post?",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Are you sure you want to delete this post?",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width:double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text("No"),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        child: Text("Yes"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isLoading = false;
  void showPostOptions(BuildContext context) async{
    Map<String, dynamic>? decodedToken = await JwtHelper.decodeToken();
    String CurrUser=decodedToken?["username"];
    showModalBottomSheet(context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(35),
          )
        )
        ,builder: (context){
       return Container(
         decoration: BoxDecoration(
           color: Colors.grey[200],
           borderRadius: const BorderRadius.vertical(
             top: Radius.circular(35),
           ),
         ),
         padding: EdgeInsets.symmetric(vertical: 38,horizontal: 28),
         child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             if(widget.post.username == CurrUser)...[
             Container(
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(12),
               ),
               child: ListTile(
                 leading: Text("Edit Post",style: TextStyle(fontFamily: "Manrope",fontWeight: FontWeight.w500,fontSize: 18),),
                 trailing: Icon(Icons.arrow_forward_ios_rounded),
                 onTap: () async {
                   Navigator.pop(context); // close bottom sheet first
                   Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (context) => EditPostPage(post:widget.post,onPostUpdated:(changes){
                         setState(() {
                           widget.post.title = changes["title"];
                           widget.post.content = changes["content"];
                           widget.post.postImage = changes["postImage"];
                         });
                       },),
                     ),
                   );
                 },
               ),
             ),
             SizedBox(height: 10),
             //delete
             GestureDetector(
               onTap: (){
                 showDeleteConfirmationDialog(context, () async {
                   setState(() {
                     _isLoading = true;
                   });

                   try {
                     bool success = await ApiService.deletePost(int.parse(widget.post.id), widget.token ?? "");

                     if (success) {
                       Navigator.pop(context); // close bottom sheet if still open
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text("Post deleted successfully")),
                       );
                       widget.onPostDelete?.call();
                     } else {
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text("Failed to delete post")),
                       );
                     }
                   } catch (e) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text("Error deleting post: $e")),
                     );
                   } finally {
                     setState(() {
                       _isLoading = false;
                     });
                   }
                 });
               },
               child: Container(
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(12),
                 ),
                 child: ListTile(
                   leading: Text("Delete Post",style: TextStyle(fontFamily: "Manrope",fontWeight: FontWeight.w500,fontSize: 18),),
                   trailing: Icon(Icons.arrow_forward_ios_rounded),
                 ),
               ),
             ),
             SizedBox(height: 10),],
             Container(
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(12),
               ),
               child: ListTile(
                 leading: Text("Hide",style: TextStyle(fontFamily: "Manrope",fontWeight: FontWeight.w500,fontSize: 18),),
                 trailing: Icon(Icons.arrow_forward_ios_rounded),
               ),
             ),
           ],
         ),
       );
    });
  }
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
        //just for the opti
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
            trailing: IconButton(onPressed: (){showPostOptions(context);},
             icon: Icon(Icons.more_vert)),
          ),

          // Post Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: widget.post.postImage,        // your post image URL
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200, // same height as your image
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
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) => SizedBox(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: CommentsSheet(postId: int.parse(widget.post.id),onCommentAdded: (){
                          setState(() {
                            widget.post.comments += 1;
                          });
                        },),
                      ),

                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.comment_outlined),
                      const SizedBox(width: 4),
                      Text("${widget.post.comments} comments"),
                    ],
                  ),
                )

              ],
            ),
          ),

          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(widget.post.content),
          ),
        ],
      ),
    );
  }
}
