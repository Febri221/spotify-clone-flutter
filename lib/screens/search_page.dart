import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF191914),
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Text('Search', style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(),
    );
  }
}