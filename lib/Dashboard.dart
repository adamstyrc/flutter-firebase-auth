import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_firebase_auth/Splash.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
      ),
      body: Center(child: RaisedButton(
        color: Colors.blue,
          child: Text("Sign out"),
          onPressed: () async {
            var googleSignIn = GoogleSignIn();
            if (await googleSignIn.isSignedIn()) {
              await googleSignIn.signOut();
            }

            var facebookLogin = FacebookLogin();
            if (await facebookLogin.isLoggedIn) {
              await facebookLogin.logOut();
            }

            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Splash()),
            );
          })),
    );
  }
}
