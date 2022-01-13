import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locationsharing/special_functions.dart' as spFunc;
import 'package:locationsharing/friend_on_map.dart' as friendMap;

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  //var username = spFunc.getStringValuesSF('username');
  //var commPass = spFunc.getStringValuesSF('commPass');

  bool setStateBool =  true;

  static var username;
  static var commPass;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<Map> _futureSF() async {
    username = await spFunc.getStringValuesSF('username');
    commPass = await spFunc.getStringValuesSF('commPass');

    return {'username': username, 'commPass': commPass};
  }

  //Future<List<String>> _futureGetFriends = _getFriends(username, commPass);

  static Future<List<String>> _getFriends() async {
    var response = await spFunc.newPost({'user':username, 'commPass':commPass}, 'getfriends');

    List<String> ls;
    if (response['reply'] == 'pass') {
      String listString = response['friends'];
      if (listString == '') {
        ls = [];
      } else {
        ls = listString.split(',');
      }
    } else {
      ls = [];
      /* setState(() {
      SnackBar snackBar = SnackBar(content: Text(response['error']));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }); */
    }

    return ls;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
      future: _futureSF(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          //debugPrint('------------------------>${snapshot.data.toString()}');
          return futureWidget();
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
      },
    );
  }

  Widget futureWidget() {
    //afterBuild();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Friends'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh, size: 27,), onPressed: refresh)
        ],
      ),
      body: Center(
        child: FutureBuilder<List<String>>(
          future: _getFriends(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return Container(
                  child: Text(
                    'Add friends to see them here!',
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.grey
                    ),
                  ),
                );
              } else {
                return _listViewWidget(snapshot.data);
              }
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      )
    );
  }

  Widget _listViewWidget(ls) {
    return ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: (ls.length)*2,
        itemBuilder: (context, i) {
          if (i.isOdd) {
            return Divider();
          } else {
            final index = i ~/ 2;
            return _buildRow(ls[index]);
          }
        });
  }

  Widget _buildRow(String name) {
    return ListTile(
      title: Text(
        name,
        style: TextStyle(fontSize: 18.0),
      ),
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(icon: Icon(Icons.map), onPressed: () { findFriendOnMap(name); } ),
          IconButton(icon: Icon(Icons.cancel), onPressed: () { removeFriend(name); } ),
        ],
      ),
    );
  }

  Future<void> removeFriend(target) async {
    spFunc.newPost({'user':username ,'commPass':commPass, 'target':target}, 'removefriend').then((Map response) {
      if (response['reply'] == 'pass') {
        refresh();

        SnackBar snackBar = SnackBar(content: Text('Successfully removed friend!'));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      } else {
        SnackBar snackBar = SnackBar(content: Text(response['error']));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    });
  }

  void findFriendOnMap(target) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => friendMap.FriendMap(),
        settings: RouteSettings(
          arguments: target,
        ),
      ),
    );
  }

  void refresh () {
    setState(() {
      setStateBool = !setStateBool;
    });
  }
}
