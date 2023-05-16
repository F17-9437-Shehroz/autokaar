import 'package:autokaar/userProfileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'addedCar.dart';

import 'carModelSelection.dart';
import 'writeBlog.dart';
import 'addedCar.dart';
import 'package:intl/intl.dart';
import 'carDetails.dart';
import 'under_construction.dart';
import 'blogOptionScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<Option> options = [
    Option('Appointment', Icons.schedule),
    Option('Blog', Icons.book),
    Option('AutoParts', Icons.build),
    Option('Set Reminder', Icons.alarm),
    Option('Nearby Mechanic', Icons.location_on),
  ];
  @override
  Widget build(BuildContext context) {
    ///
    ///
    final User? user = _auth.currentUser;
    final String userId = user?.uid ?? '';
    return WillPopScope(
        onWillPop: () async {
          // Save current login user here

          // Close the app
          SystemNavigator.pop();
          return false;
        },

        ///
        child: Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SelectCarScreen()),
                );
              },
              icon: Icon(Icons.directions_car),
              label: Text('Add a Car'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            appBar: AppBar(
              title: Text('AutoKaar'),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UnderConstructionScreen()),
                    );
                  },
                  icon: Stack(
                    children: [
                      Icon(Icons.chat),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            '2',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.black,
                    ),
                    child: Text(
                      'AutoKaar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Profile'),
                    onTap: () {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserProfileScreenX(user: user),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: Text('User not found.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.arrow_back),
                    title: Text('Switch mode'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            body: Column(children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('userCar')
                      .where('uid', isEqualTo: userId) // Filter by user ID
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = snapshot.data!.docs[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CarLogScreen(
                                  carID: document['carID'],
                                ),
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            margin: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            padding: EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Hero(
                                  tag: document['urlS'],
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      document['urlS'],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        document['company'],
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        document['carModel'],
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.grey),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        document['current'].toString(),
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        formatTimestamp(document['timestamp']),
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ); //
                  },
                ),
              ),
              Expanded(
                  child: GridView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: options.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                            onTap: () {
                              if (index == 1) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BottomMenuScreen()),
                                );
                              }
                              if (index == 0) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UnderConstructionScreen()),
                                );
                              }
                              if (index == 2) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UnderConstructionScreen()),
                                );
                              }
                              if (index == 3) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UnderConstructionScreen()),
                                );
                              }
                              if (index == 4) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UnderConstructionScreen()),
                                );
                              }
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(options[index].icon, size: 48),
                                  SizedBox(height: 16),
                                  Text(
                                    options[index].name,
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ) //an
                            );
                      }))
            ])));
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return '';
    }

    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat.yMMMd().format(dateTime);
    String formattedTime = DateFormat.jm().format(dateTime);

    return '$formattedDate $formattedTime';
  }
}

class Option {
  final String name;
  final IconData icon;

  Option(this.name, this.icon);
}
