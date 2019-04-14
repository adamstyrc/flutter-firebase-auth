# Flutter: Sign in with Firebase!

Flutter very recommends using Firebase with it's full powers. Curious how to implement all the most common Sign In approaches like Faceook Login or Google Sign In? Moreover, to do it painless and avoid all mistakes? Jump in to check it out!

## Setting up
First you will need to visit [Firebase Console](https://console.firebase.google.com/) and create your project.

Then follow all steps for integrating Android & iOS - this article won't cover that.

We'll start with **Flutter firebase_auth** by adding a dependency in *pubspec.yaml*:

  >  firebase_auth: ^0.8.0+1

Launch your project to briefly check if all is fine.

**Android**
Note if you face runtime error like below:
![enter image description here](https://i.postimg.cc/KYn1r89M/Screenshot-2019-04-01-22-31-16.png)
which is a problem with AndroidX compatibility please add these 2 lines to your *gradle.properties* file:

    android.useAndroidX=true  
    android.enableJetifier=true

## Basics - building layout

We would like to display **Login** screen to a user only if user is not yet logged in so in this article we will try an easy check in e.g. your **Splash** screen.

>Splash.dart
```dart 
import 'package:flutter/material.dart';  
import 'package:firebase_auth/firebase_auth.dart';  
  
class Splash extends StatelessWidget {  
  @override  
  Widget build(BuildContext context) {  
    FirebaseAuth.instance.currentUser().then((user) {  
	    var userLoggedIn = user != null;  
	    if (userLoggedIn) {  
	        //...  
	    } else {  
		    Navigator.pushReplacement(  
			    context, MaterialPageRoute(builder: (context) => Login()),  
	        );  
	    }  
	});  
  
  return Container(  
	  color: Colors.blue,  
	  child: Align(  
		  child: Theme(  
            child: CircularProgressIndicator(),  
            data: Theme.of(context)  
                .copyWith(accentColor: Colors.white)
            ),  
	      alignment: Alignment(0.0, 0.4)  
      )
   );  
  }  
}
```

Let's build now Login form!
>Login.dart
```dart
import 'package:flutter/material.dart';  
  
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
          title: Text("Login Screen")
        ),
        body: ListView(  
          padding: EdgeInsets.all(15.0),
          children: <Widget>[  
            TextField(  
                controller: _emailTextController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress
            ),
            TextField(
	            controller: _passwordTextController,
	            decoration: InputDecoration(labelText: 'Password'),
	            obscureText: true
            ),
            RaisedButton(
	            child: Text("Sign in"),
	            color: Colors.blue,
	            onPressed: () {  
//                ...  
		    })  
          ],  
  ));  
  }  
}
```

## Basics - email/password sign in

Now let's implement actual sign in with Firebase, that would be wired with:
> onPressed: _handleSignIn
``` dart
void _handleSignIn() async {  
    var email = _emailTextController.text.trim(); 
    var password = _passwordTextController.text.trim();  
  
    FirebaseUser firebaseUser = await FirebaseAuth.instance  
	  .signInWithEmailAndPassword(email: email, password: password);  
  
    if (firebaseUser != null) {  
//        goToNextScreen();  
    }  
 }
  ```

**Auth Token**
FirebaseUser instance contains couples of interesting parameters, especially when you login with Facebook or Google which we will cover in a while. 

However the most important is obtaining **user token** For this we need to call a Future:
```dart 
String firebaseToken = await firebaseUser.getIdToken();
```

On your backend you will probably need to check that token with Firebase SDK if user is correctly logged in on each request.

## Errors

In code above we just covered a happy path of successful sign in. What we would like to handle error cases like e.g. wrong password?

We need to cover our code with try catch block:
```dart
try {
	FirebaseAuth.instance.signInWithEmailAndPassword()
} on PlatformException catch (error) {
	// Here you can handle your error message
}
```

Here is a list of sign in errors:

 - User provided empty email / password field:

> PlatformException(error, Given String is empty or null, null)
 - User provided email in invalid format:

> PlatformException(ERROR_INVALID_EMAIL, The email address is badly formatted., null)

 - User provided nonexistent email:

> PlatformException(ERROR_USER_NOT_FOUND, There is no user record corresponding to this identifier. The user may have been deleted., null)

 - User provided wrong password for an email:

> PlatformException(ERROR_WRONG_PASSWORD, The password is invalid or the user does not have a password., null)

- No internet connection:
> PlatformException(ERROR_NETWORK_REQUEST_FAILED, A network error (such as timeout, interrupted connection or unreachable host)., null)


## Google Sign In

In order to use Google Sign In, let's add a dependency to *pubspec.yaml*:
> google_sign_in: ^4.0.0

full installation is available at:
>[https://pub.dartlang.org/packages/google_sign_in](https://pub.dartlang.org/packages/google_sign_in)

To trigger Google Sign In, let's add some code (e.g. Login.dart) triggered on some another button:
```dart 
import 'package:google_sign_in/google_sign_in.dart';

...

void _handleGoogleSignIn() async {  
  GoogleSignIn _googleSignIn = GoogleSignIn(  
    scopes: [
    // We ask for minimal access  
      'email',  
  ],  
  );  
  
  GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();  
  GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;  
}
```
This will open Google Login screen dependent on platform:
 - on **iOS** a modal with web page - full credential login required
 - on **Android** nonfullscreen sign in which only asks to choose an account (because of Gmail app)

Once we have **googleAuth** object we need to pass it to Firebase:
```dart 
  final AuthCredential credential = GoogleAuthProvider.getCredential(  
    accessToken: googleAuth.accessToken,  
  idToken: googleAuth.idToken,  
  );
    
  firebaseUser = await FirebaseAuth.instance.signInWithCredential(credential);
```

Possible **exception** is e.g.:
> PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 7: , null)
> 
## Facebook Login
I used a flutter package:
> [flutter_facebook_login](https://pub.dartlang.org/packages/flutter_facebook_login)

If will be required to set Facebook Developer account and create an app. Follow full instruction from link above.

To enable Facebook Login, let's add another dependency:
> flutter_facebook_login: ^2.0.0

Here a code for triggering Facebook Login screen and integrating with Firebase would be:
```dart
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
      final facebookToken = result.accessToken.token;
	  var credential = FacebookAuthProvider.getCredential(  
          accessToken: facebookToken 
      );  
  
  FirebaseUser firebaseUser = await FirebaseAuth.instance.signInWithCredential(credential);  
  }  
}
```

Once again we just ask for minimal data so no permissions from FB are required. What is interesting, you can use FB Graph API to obtain more info about user:

>final graphResponse = await http.get(  
    'https://graph.facebook.com/v2.12/me?fields=first_name,email&access_token=${facebookToken}');

Or to get user's avatar in particular size e.g. 200x200:
>https://graph.facebook.com/{facebookToken}/picture?width=200&height=200

## Signing out
To sign out from Firebase we only need  to call one method *signOut()* but let's not forget to make sure we've log out from Google / Facebook if users logged this way...
```dart
if (await googleSignIn.isSignedIn()) {  
  await googleSignIn.signOut();  
}  
  
if (await FacebookLogin().isLoggedIn) {  
  await facebookLogin.logOut();  
}  
  
await FirebaseAuth.instance.signOut();
```
## Creating new user

Stay tuned for next article **Flutter: Sign up with Firebase (part 2)** !