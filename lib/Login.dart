import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase_auth/Dashboard.dart';

class Login extends StatefulWidget {
  @override
  State createState() => LoginState();
}

class LoginState extends State<Login> {
  TextEditingController _emailTextController;
  TextEditingController _passwordTextController;

  @override
  void initState() {
    super.initState();

    _emailTextController = TextEditingController();
    _passwordTextController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Login Screen"),
        ),
        body: ListView(
          padding: EdgeInsets.all(15.0),
          children: <Widget>[
            TextField(
                controller: _emailTextController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress),
            TextField(
                controller: _passwordTextController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true),
            RaisedButton(
              child: Text("Sign in"),
              color: Colors.blue,
              onPressed: _handleSignIn
            ),
            RaisedButton(
                child: Text("Google"),
                color: Colors.white,
                onPressed: _handleGoogleSignIn
            ),
            RaisedButton(
                child: Text("Facebook"),
                color: Colors.white,
                onPressed: _handleFacebookSignIn
            )
          ],
        ));
  }

  void _handleSignIn() async {
    var email = _emailTextController.text.trim();
    var password = _passwordTextController.text.trim();

    try {
      FirebaseUser firebaseUser = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: email, password: password);

      if (firebaseUser != null) {
              _goToNextScreen();
          }
    } on PlatformException catch (error) {
      print(error);
    }
  }

  void _handleGoogleSignIn() async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
      ],
    );

    try {
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      FirebaseUser firebaseUser = await FirebaseAuth.instance.signInWithCredential(credential);
      if (firebaseUser != null) {
        _goToNextScreen();
      }
    } on PlatformException catch (error) {
      print(error);
    }
  }

  void _handleFacebookSignIn() async {
    final facebookLogin = FacebookLogin();

    final facebookLoginResult = await facebookLogin
        .logInWithReadPermissions(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");

        var credential = FacebookAuthProvider.getCredential(
            accessToken: facebookLoginResult.accessToken.token
        );

        try {
          FirebaseUser firebaseUser = await FirebaseAuth.instance.signInWithCredential(credential);
          if (firebaseUser != null) {
                    _goToNextScreen();
                  }
        } on PlatformException catch (e) {
          print(e);
        }
    }
  }

  void _goToNextScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Dashboard()),
    );
  }
}
