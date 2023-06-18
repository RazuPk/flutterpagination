// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const PaginationApp());
}

class PaginationApp extends StatelessWidget {
  const PaginationApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PostViewScreen(),
    );
  }
}

class PostViewScreen extends StatefulWidget {
  const PostViewScreen({
    super.key,
  });

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  List<dynamic> posts = [];
  int currentPage = 0;
  int postPerPage = 5;
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  Future<void> getPostsData() async {
    final apiUrl = 'https://jsonplaceholder.typicode.com/posts?_start=$currentPage&_limit=$postPerPage';
    setState(() {
      isLoading = true;
    });
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final postData = jsonDecode(response.body);
      setState(() {
        posts.addAll(postData);
        currentPage += postPerPage;
        isLoading = false;
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('No data found'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getPostsData();

    _scrollController.addListener(() {
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
        getPostsData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        centerTitle: true,
      ),
      body: ListView.builder(
          controller: _scrollController,
          itemCount: posts.length + 1,
          itemBuilder: (context, index){
          if(index == posts.length){
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: (){
                  getPostsData();
                }, child: const Text('Loan More')),
              ),
            );
          }else{
            return Card(
              elevation: 3,
              child: ListTile(
                leading: Text(
                    (index + 1).toString(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  title: Text(
                    posts[index]['title'],
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(posts[index]['body']),
                ),
            );
          }
      }),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
