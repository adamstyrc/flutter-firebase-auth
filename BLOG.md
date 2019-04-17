

Today, most of mobile applications requires user to sign in. To share state between devices, introduce social aspect into an application. This is so common use case, so instead of inventing wheel from the begging let's try to reuse existing solutions. My choice was Firebase. In the next couple of paragraphs I will present how to enable Facebook or Google authentication in painless way, mitigating all obstacles.

## Firebase

Firebase is a platform that can help develop mobile and web apps quicker. Collections of provided tools is wide and reaches from push messages (in the past: Google Cloud Messaging) through  analytics (Google Analytics), AB testing and cloud database (Firestore). Most for free :) A tool that we going to use today is Firebase Auth.

## Setting up
First you will need to visit [Firebase Console](https://console.firebase.google.com/) and create your project. Then enable Firebase Authentication Sign-In methods for Email/Password, Google and Facebook.

Next follow all steps for integrating Android & iOS - this article won't cover that :(

We'll start with **Flutter firebase_auth** by adding a dependency in *pubspec.yaml*:

  >  firebase_auth: ^0.8.0+1

Launch your project to briefly check if all is fine.

**Android**
Note if you face runtime error like below:

![/Users/adamstyrc/utils/flutter/.pub-cache/hosted/pub.dartlang.org/firebase_auth-0.8.3/android/src/main/java/io/flutter/plugins/firebaseauth/FirebaseAuthPlugin.java:9: error: cannot find symbol
import androidx.annotation.NonNull;
                          ^
  symbol:   class NonNull
  location: package androidx.annotation
/Users/adamstyrc/utils/flutter/.pub-cache/hosted/pub.dartlang.org/firebase_auth-0.8.3/android/src/main/java/io/flutter/plugins/firebaseauth/FirebaseAuthPlugin.java:10: error: cannot find symbol
import androidx.annotation.Nullable;](https://i.postimg.cc/KYn1r89M/Screenshot-2019-04-01-22-31-16.png)

which is a problem with AndroidX compatibility please add these 2 lines to your *gradle.properties* file:

    android.useAndroidX=true  
    android.enableJetifier=true

## Basics - building layout

We would like to display **Login** screen for a user only if is not yet logged in so we will try an easy checking with *if* statement on e.g. your **Splash** screen. Note the screen will have some progress bar ;)

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

Now let's build the most desired UI - a **Login** form. We'll put all sign in methods that we prefer: email/password, Google and Facebook.
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
}
```

## Email/password sign in

It's good idea to start off from basics so we'll implement email/password sign in first. We are going to use a callback for 'Sign in" button *_handleSignIn* and wire it with the code:
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
FirebaseUser object has couples of interesting fields, especially when you login with Facebook or Google - which we will cover in a while.
However, the most important for now is obtaining **user token**. For this purpose we need to call a method on FirebaseUser:
```dart 
String firebaseToken = await firebaseUser.getIdToken();
```

On your backend in each requests you will probably need to check the token validity with Firebase SDK.

### Exceptions on your log in

In code above we just covered a happy path of successful sign in. But what if we would like to handle error cases like e.g. wrong password? Firebase answers with **PlatformException** and proper code and message!

In order to make use of this exception, we need cover our code with try catch block:
```dart
try {
  FirebaseAuth.instance.signInWithEmailAndPassword()
} on PlatformException catch (error) {
  // Here you can handle your error message
}
```

Here is a list of sign in errors I managed to track:

 - User provided empty email / password field:

  > PlatformException(error, Given String is empty or null, null)
 - User provided email in invalid format:

  > PlatformException(ERROR\_INVALID\_EMAIL, The email address is badly formatted., null)

 - User provided nonexistent email:

  > PlatformException(ERROR\_USER\_NOT\_FOUND, There is no user record corresponding to this identifier. The user may have been deleted., null)

 - User provided wrong password for an email:

> PlatformException(ERROR\_WRONG\_PASSWORD, The password is invalid or the user does not have a password., null)

- No internet connection:
  > PlatformException(ERROR\_NETWORK\_REQUEST\_FAILED, A network error (such as timeout, interrupted connection or unreachable host)., null)


## Google Sign In

When plugging Google Sign In, let's add a dependency to *pubspec.yaml*:
Please check what is a latest version
  > google\_sign\_in: ^4.0.0

full installation is available at:
>[https://pub.dartlang.org/packages/google_sign_in](https://pub.dartlang.org/packages/google_sign_in)

To trigger Google Sign In, let's add some code (e.g. Login.dart) triggered on another button 'Google':
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

Once we obtain **googleAuth** object we need to pass it to Firebase:
```dart 
  final AuthCredential credential = GoogleAuthProvider.getCredential(  
    accessToken: googleAuth.accessToken,  
  idToken: googleAuth.idToken,  
  );
    
  firebaseUser = await FirebaseAuth.instance.signInWithCredential(credential);
```

Possible **exception** is once again PlatformException. When user changes his mind and leaves the SignIn modal you also get:
  > PlatformException(sign\_in\_failed, com.google.android.gms.common.api.ApiException: 7: , null)
You could for example catch that event and report to your analytics to indicate users are somehow pushed away from logging in with Google.

## Facebook Login
For this blog post I used below flutter package:
  > [flutter\_facebook\_login](https://pub.dartlang.org/packages/flutter_facebook_login)

but there could be other libraries. At the time of writing this article there is no official one ;)

Please keep in mind it will be required to set Facebook Developer account and create an app. Follow full instruction from link above.

To enable Facebook Login, let's add another dependency:
Please mention what is a latest version
  > flutter\_facebook\_login: ^2.0.0

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
> 'https://graph.facebook.com/v2.12/me?fields=first\_name,email&access\_token=${facebookToken}');

Or to get user's avatar in particular size e.g. 200x200:
>https://graph.facebook.com/{facebookToken}/picture?width=200&height=200

## Additionals
Do you remember on each sign in we end up with FirebaseUser object? If we look at it precisely there are some data that we could squeeze out to learn more about user.

 - **Display Name** - I noticed in case of Google sign in you get name and surname and in case of Facebook you only get user's name.
 - **Email** - you get in when logging with each of this method, quite unobvious you can get it when logging with Facebook
 - **Creation timestamp** & **Last SignIn timestamp** - what comes to my mind is that it might be useful to welcome comming back users?
 
 ### Multiple sign in with one email 
Also, in Firebase Console, in Account email address setting, you can set option to **merge accounts** signed on the same email. What does it mean? Imagine you first signed up by email/password using *blabla@gmail.com* but at the second login you choose Google Sign In with the same email address. How to cope with that ? If you enable this option, user will be treated as the same user but using multiple sign in methods. When logging with Google your Firebase Auth will only get more "aware" of this user. If you don't enable that, PlatformException will occur:

> PlatformException(ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL, An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address., null)
 
## Signing out
To sign out from Firebase we only need  to call one method *signOut()* but let's not forget to make sure we've log out from Google / Facebook if users logged this way...
```dart
var googleSignIn = GoogleSignIn();  
if (await googleSignIn.isSignedIn()) {  
  await googleSignIn.signOut();  
}  
  
var facebookLogin = FacebookLogin();  
if (await facebookLogin.isLoggedIn) {  
  await facebookLogin.logOut();  
}  
  
await FirebaseAuth.instance.signOut();
```
## Creating new user

Stay tuned for next article **Flutter: Authentication with Firebase (part 2)** ! :)

Whole code used in this article is available here:
> https://github.com/adamstyrc/flutter-firebase-auth
