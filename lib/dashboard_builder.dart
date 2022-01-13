import 'package:flutter/material.dart';
import 'package:locationsharing/friends_list.dart' as friendsList;
import 'package:locationsharing/social_page.dart' as socialPage;

class DashBuilder extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Dash(),
    );
  }
}

class Dash extends StatefulWidget {
  @override
  _DashState createState() => _DashState();
}

class _DashState extends State<Dash> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    friendsList.FriendsList(),
    socialPage.SocialPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.navigation),
            title: new Text('Find'),
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.people),
            title: new Text('Social'),
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}

