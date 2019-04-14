import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_auth/Dashboard.dart';
import 'package:flutter_firebase_auth/Login.dart';

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.currentUser().then((user) {
      var userLoggedIn = user != null;
      if (userLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    });

    return Container(
        color: Colors.blue,
        child: Align(
            child: Theme(
                child: CircularProgressIndicator(),
                data: Theme.of(context).copyWith(accentColor: Colors.white)),
            alignment: Alignment(0.0, 0.4)));
  }
}
