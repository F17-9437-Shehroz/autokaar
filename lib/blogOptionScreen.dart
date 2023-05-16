import 'package:flutter/material.dart';
import 'MyBlogScreen.dart';
import 'PublicBlogScreen.dart';

class BottomMenuScreen extends StatefulWidget {
  @override
  _BottomMenuScreenState createState() => _BottomMenuScreenState();
}

class _BottomMenuScreenState extends State<BottomMenuScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    MyBlogScreen(),
    PublicBlogScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bottom Menu'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue, // Set the background color to blue
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.edit,
                color: Colors.white), // Set the icon color to white
            label: 'My Blog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public,
                color: Colors.white), // Set the icon color to white
            label: 'Public Blog',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor:
            Colors.white, // Set the selected item text color to white
        onTap: _onItemTapped,
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: BottomMenuScreen(),
  ));
}
