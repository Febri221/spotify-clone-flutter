import 'package:flutter/material.dart';

class LibraryHeader extends StatelessWidget {

  final bool isGrid;
  final VoidCallback onToggleView;

  LibraryHeader({required this.isGrid, required this.onToggleView});

  @override
  Widget build(BuildContext context) {
     return Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 16.0, top: 8.0),
          child: Icon(Icons.arrow_downward, size: 20, color: Colors.white),
        ),
        Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Icon(Icons.arrow_upward, size: 20, color: Colors.white),
        ),
        Padding(
          padding: EdgeInsets.only(left: 4.0, top: 8.0),
          child: Text(
            'Recents',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        Spacer(),
        Padding(
          padding: EdgeInsets.only(right: 8.0, top: 16.0),
          child: IconButton(
            icon: Icon(
              isGrid ? Icons.list : Icons.grid_view,
              color: Colors.white,
            ),
            onPressed: onToggleView,
          ),
        ),
      ],
    );;
  }
}