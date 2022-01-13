import 'package:flutter/material.dart';
import 'package:locationsharing/special_functions.dart' as spFunc;

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(hintText: 'Username'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(hintText: 'Password'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RaisedButton(
                child: Text('Sign Up'),
                onPressed: trySignUp,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                child: Text("Already have an account? Log In!"),
                onPressed: goToLogIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  trySignUp() {
    spFunc.newPost({'user':_usernameController.text,'password':_passwordController.text}, 'signup').then( (Map response) {
      //debugPrint('-----------------------------> $response');

      if (response['reply'] == 'pass') {
        setState(() {
          SnackBar snackBar = SnackBar(content: Text('Signed Up successfully'));
          _scaffoldKey.currentState.showSnackBar(snackBar);

          goToLogIn();
        });
      } else {
        setState(() {
          SnackBar snackBar = SnackBar(content: Text(response['error']));
          _scaffoldKey.currentState.showSnackBar(snackBar);
        });
      }
    } );

  }

  goToLogIn() {
    Navigator.pop(context);
  }

}
