import 'package:autokaar/loginMain.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileScreenX extends StatelessWidget {
  final User user;

  const UserProfileScreenX({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future:
            FirebaseFirestore.instance.collection('Users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return Center(
              child: Text('No user data found.'),
            );
          }
          final userData = snapshot.data?.data();
          return Center(
            child: Column(
              children: [
                Text('Email: ${userData?['email'] ?? 'N/A'}'),
                Text('Name: ${userData?['name'] ?? 'N/A'}'),
                Text('City: ${userData?['city'] ?? 'N/A'}'),
                ElevatedButton(
                  onPressed: () {
                    logout(context);
                  },
                  child: Text('Logout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void logout(BuildContext context) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      await auth.signOut();
      // Clear user information or perform any necessary logout logic here
      // ...

      // Navigate to the login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => MyLoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Handle any errors that occurred during the logout process
      print('Error logging out: $e');
    }
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
