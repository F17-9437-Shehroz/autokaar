import 'package:autokaar/writeBlog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'blogDetialscreen.dart';

class MyBlogScreen extends StatelessWidget {
  String cuid = FirebaseAuth.instance.currentUser!.uid.toString();

  @override
  Widget build(BuildContext context) {
    print(cuid);
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => blogdata()),
                );
              },
              icon: Icon(Icons.edit),
              label: Text('Write Blog'),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('mechanicUserBlog')
                  .where('uploaderUid', isEqualTo: cuid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final blogs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: blogs.length,
                  itemBuilder: (context, index) {
                    final blog = blogs[index].data() as Map<String, dynamic>;
                    final imageLink = blog['imageLink'] ?? '';
                    final blogID = blog['blogID'] ?? '';
                    final uploaderID = blog['uploaderUid'] ?? '';
                    final title = blog['title'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlogDetailsScreen(
                              blogID: blogID,
                              uploaderID: uploaderID,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageLink,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
