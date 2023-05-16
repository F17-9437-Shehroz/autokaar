import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mainScreenApp.dart';
import 'loginMain.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBsVJigQx2mYyPniP8IEEy4uf6OBd8fPaQ",
      appId: "1:804072962663:android:116d63c88a0805c54d32c2",
      messagingSenderId: "804072962663",
      projectId: "autokaar-d1104",
      storageBucket: "autokaar-d1104.appspot.com",
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AuthenticationWrapper(); // your main screen
          }
          if (snapshot.hasError) {
            return ErrorScreen(); // create an error screen widget
          }
          return SplashScreen(); // your splash screen
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Loading...'), // Customize this to fit your need
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
            'Error Initializing Firebase'), // Customize this to fit your need
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      return MainScreen(); // if user is logged in, redirect to MainScreen
    } else {
      return MyLoginScreen(); // if user is not logged in, redirect to MyLoginScreen
    }
  }
}
