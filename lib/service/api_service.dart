import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/comment.dart';
import '../models/post.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  static Future<List<Post>> fetchPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));


      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('Successfully fetched ${data.length} posts');
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection or server unreachable');
    } on TimeoutException catch (e) {
      throw Exception('Request timeout');
    } on FormatException catch (e) {
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }

  static Future<List<Comment>> fetchComments(int postId) async {
    try {
      print('Fetching comments for post $postId');
      final response = await http.get(
        Uri.parse('$baseUrl/posts/$postId/comments'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('Successfully fetched ${data.length} comments');
        return data.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load comments: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Failed to load comments: $e');
    }
  }

  static Future<User> fetchUser(int userId) async {
    try {
      print('Fetching user $userId');
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('Successfully fetched user $userId');
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('SocketException in fetchUser: $e');
      throw Exception('No internet connection');
    } catch (e) {
      print('Exception in fetchUser: $e');
      throw Exception('Failed to load user: $e');
    }
  }
}