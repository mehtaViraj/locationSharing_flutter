import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locationsharing/special_functions.dart' as spFunc;
import 'package:locationsharing/main.dart' as mainPage;
import 'package:locationsharing/dashboard_builder.dart' as dashB;

class SocialPage extends StatefulWidget {
  @override
  _SocialPageState createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  //var username = spFunc.getStringValuesSF('username');
  //var commPass = spFunc.getStringValuesSF('commPass');

  bool setStateBool = true;

  static var username;
  static var commPass;

  final _addFriendsController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //Future<Map> _futureGetSocialCode = spFunc.newPost({'user': username.toString(), 'commPass': commPass.toString()}, 'getsocialcode');

  Future<Map> _futureGetSocialCode () async {
    var response = await spFunc.newPost({'user': username.toString(), 'commPass': commPass.toString()}, 'getsocialcode');
    return response;
  }

  Future<Map> _futureSF() async {
    username = await spFunc.getStringValuesSF('username');
    commPass = await spFunc.getStringValuesSF('commPass');

    return {'username': username, 'commPass': commPass};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
      future: _futureSF(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
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
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Add Friends'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Your Social Code:',
                    style: TextStyle(fontSize: 23),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FutureBuilder(
                        future: _futureGetSocialCode(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data['reply'] == 'pass') {
                              return Text(
                                snapshot.data['socialCode'],
                                style: TextStyle(
                                  fontSize: 35,
                                  color: Colors.red,
                                ),
                              );
                            }
                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }
                          return CircularProgressIndicator();
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: IconButton(
                          icon: Icon(Icons.refresh),
                          iconSize: 45,
                          onPressed: changeSocialCode,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 200,
                        child: TextField(
                            controller: _addFriendsController,
                            decoration: InputDecoration(
                                hintText:
                                "Friend's social code")
                        ),
                      ),
                      RaisedButton(
                        child: Text('ADD'),
                        onPressed: tryFriendAdd,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 200),
                  child: RaisedButton(
                    child: Text('LOG OUT'),
                    onPressed: logOut,
                  ),
                ),
              ],
            ),
        ),
        ),
    );
  }

  Future<void> changeSocialCode() async {
    spFunc.newPost({'user': username, 'commPass': commPass}, 'changesocialcode').then((Map response) {
      if (response['reply'] == 'pass') {
        setState(() {
          setStateBool = !setStateBool;
        });
      } else {
        SnackBar snackBar = SnackBar(content: Text(response['error']));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    });
  }

  Future<void> tryFriendAdd() async {
    spFunc.newPost({'user':username ,'commPass':commPass, 'target':_addFriendsController.text}, 'addfriend').then((Map response) {
      if (response['reply'] == 'pass') {
        SnackBar snackBar = SnackBar(content: Text('Successfully added friend!'));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      } else {
        SnackBar snackBar = SnackBar(content: Text(response['error']));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    });
  }

  Future<void> logOut () async {
    spFunc.newPost({'user':username ,'commPass':commPass}, 'logout').then((Map response) {
      if (response['reply'] == 'pass') {
        //SnackBar snackBar = SnackBar(content: Text('Logged Out, restart the app.'));
        //_scaffoldKey.currentState.showSnackBar(snackBar);

        spFunc.addStringToSF('username', 'null');
        spFunc.addStringToSF('commPass', 'null');

        int count = 0;
        Navigator.pushReplacementNamed(context, '/');
      } else {
        SnackBar snackBar = SnackBar(content: Text(response['error']));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    });
  }

}
