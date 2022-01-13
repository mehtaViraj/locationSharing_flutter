import 'package:flutter/material.dart';
import 'package:locationsharing/special_functions.dart' as spFunc;
import 'package:locationsharing/sign_up.dart' as signUp;
import 'package:locationsharing/dashboard_builder.dart' as dashB;

void main() {
  runApp(MyApp());
  spFunc.updateLocationCron();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/signUp': (context) => signUp.SignUp(),
        '/dashB': (context) => dashB.DashBuilder()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  //MyHomePage({Key key, this.title}) : super(key: key);

   //final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future<void> afterBuild (context) async {
    var commPass = await spFunc.getStringValuesSF('commPass') ?? 'null';
    //debugPrint('------------------>${commPass.toString()}');
    if ((commPass != 'null')&&(commPass != null)) {
      Navigator.pushReplacementNamed(context, '/dashB');
    }
  }

  @override
  Widget build(BuildContext context) {
    //WidgetsBinding.instance.addPostFrameCallback((_) => afterBuild);
    afterBuild(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Login'),
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
                child: Text('Log In'),
                onPressed: tryLogIn,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FlatButton(
                child: Text("Don't have an account? Sign up!"),
                onPressed: goToSignUp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  tryLogIn() {
    spFunc.newPost({'user':_usernameController.text,'password':_passwordController.text}, 'login').then( (Map response) {
      //debugPrint('-----------------------------> $response');

      if (response['reply'] == 'pass') {
        setState(() {
          SnackBar snackBar = SnackBar(content: Text('Logged in successfully'));
          _scaffoldKey.currentState.showSnackBar(snackBar);

          spFunc.addStringToSF('username', _usernameController.text);
          spFunc.addStringToSF('commPass', response['commPass']);
          Navigator.pushReplacementNamed(context, '/dashB');
        });
      } else {
        setState(() {
          SnackBar snackBar = SnackBar(content: Text(response['error']));
          _scaffoldKey.currentState.showSnackBar(snackBar);
        });
      }
    } );

  }

  goToSignUp() {
    Navigator.pushNamed(context, '/signUp');
  }

}
