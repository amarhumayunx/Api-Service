class Comment {
  final int id;
  final int postId;
  final String name;
  final String email;
  final String body;
  List<Comment>? replies;

  Comment({
    required this.id,
    required this.postId,
    required this.name,
    required this.email,
    required this.body,
    this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    List<Comment>? repliesList;
    if (json['replies'] != null) {
      repliesList = (json['replies'] as List)
          .map((reply) => Comment.fromJson(reply))
          .toList();
    }

    return Comment(
      id: json['id'],
      postId: json['postId'],
      name: json['name'],
      email: json['email'],
      body: json['body'],
      replies: repliesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'name': name,
      'email': email,
      'body': body,
      'replies': replies?.map((reply) => reply.toJson()).toList(),
    };
  }
}