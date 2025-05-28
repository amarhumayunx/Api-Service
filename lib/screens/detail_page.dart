import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../models/post.dart';
import '../service/api_service.dart';

class DetailPage extends StatefulWidget {
  final Post post;
  final String userName;

  DetailPage({required this.post, required this.userName});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<Comment> comments = [];
  bool isLoading = true;
  bool isLiked = false;
  int likeCount = 67;
  int commentCount = 0;
  int shareCount = 5;

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  Future<void> loadComments() async {
    try {
      final fetchedComments = await ApiService.fetchComments(widget.post.id);
      setState(() {
        comments = fetchedComments;
        commentCount = comments.length;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
  }

  Widget buildComment(Comment comment, {bool isReply = false, int level = 0}) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 12,
        left: isReply ? 40.0 * level : 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isReply ? 16 : 20,
            backgroundColor: Colors.grey[300],
            child: Icon(
              Icons.person,
              size: isReply ? 16 : 20,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.name.split(' ').take(2).join(' '),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isReply ? 14 : 15,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Nov 12',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isReply ? 13 : 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  comment.body,
                  style: TextStyle(
                    fontSize: isReply ? 14 : 15,
                    height: 1.4,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 5),
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.thumb_up_outlined,
                              color: Colors.grey[600],
                              size: isReply ? 16 : 18),
                          SizedBox(width: 6),
                          Text(
                            (25 + comment.id * 5).toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isReply ? 13 : 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Row(
                        children: [
                          Icon(Icons.thumb_down_outlined,
                              color: Colors.grey[600],
                              size: isReply ? 16 : 18),
                          SizedBox(width: 6),
                          Text(
                            (comment.id + 1).toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isReply ? 13 : 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      if (!isReply)
                        InkWell(
                          onTap: () {
                            showReplyDialog(comment);
                          },
                          child: Text(
                            'Reply',
                            style: TextStyle(
                              color: Colors.blue[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (comment.replies != null && comment.replies!.isNotEmpty)
                  Column(
                    children: comment.replies!.map((reply) =>
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: buildComment(reply, isReply: true, level: level + 1),
                        )
                    ).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showReplyDialog(Comment parentComment) {
    TextEditingController replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reply to ${parentComment.name}'),
          content: TextField(
            controller: replyController,
            decoration: InputDecoration(
              hintText: 'Write your reply...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (replyController.text.isNotEmpty) {
                  addReply(parentComment, replyController.text);
                  Navigator.pop(context);
                }
              },
              child: Text('Reply'),
            ),
          ],
        );
      },
    );
  }

  void addReply(Comment parentComment, String replyText) {
    setState(() {
      Comment newReply = Comment(
        id: DateTime.now().millisecondsSinceEpoch,
        postId: parentComment.postId,
        name: widget.userName,
        email: 'user@example.com',
        body: replyText,
      );

      for (int i = 0; i < comments.length; i++) {
        if (comments[i].id == parentComment.id) {
          if (comments[i].replies == null) {
            comments[i].replies = [];
          }
          comments[i].replies!.add(newReply);
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Post', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            SizedBox(height: 16),

            Text(
              widget.post.body,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: toggleLike,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.grey[600],
                            size: 30,
                          ),
                          SizedBox(width: 8),
                          Text(
                            likeCount.toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            color: Colors.grey[600],
                            size: 30),
                        SizedBox(width: 8),
                        Text(
                          commentCount.toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.ios_share, color: Colors.grey[600], size: 30),
                        SizedBox(width: 8),
                        Text(
                          shareCount.toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            InkWell(
              onTap: () {
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Most Relevant',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, color: Colors.black),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            if (isLoading)
              Center(child: CircularProgressIndicator())
            else
              Column(
                children: comments.map((comment) =>
                    Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: buildComment(comment),
                    )
                ).toList(),
              ),

            SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    size: 20,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Add comment ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Icon(Icons.image_outlined, color: Colors.grey[600]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}