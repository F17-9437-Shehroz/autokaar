import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mainScreenApp.dart';
import 'loginMain.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: "AIzaSyBsVJigQx2mYyPniP8IEEy4uf6OBd8fPaQ",
    appId: "1:804072962663:android:116d63c88a0805c54d32c2",
    messagingSenderId: "804072962663",
    projectId: "autokaar-d1104",
    storageBucket: "autokaar-d1104.appspot.com",
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Persistent Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingScreen();
          } else {
            if (snapshot.data == true) {
              return MainScreen();
            } else {
              return MyLoginScreen();
            }
          }
        },
      ),
    );
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    return uid != null;
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
