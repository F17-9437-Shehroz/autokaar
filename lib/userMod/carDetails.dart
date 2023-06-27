import 'package:autokaar/userMod/editLogScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CarLogScreen extends StatelessWidget {
  final String carID;

  CarLogScreen({required this.carID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Log'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('carlog').doc(carID).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('No data available'),
            );
          }

          var logData = snapshot.data!.data() as Map<String, dynamic>;
          Timestamp frontright = logData['frontright'];
          Timestamp frontleft = logData['frontleft'];
          Timestamp backright = logData['backright'];
          Timestamp backleft = logData['backleft'];
          Timestamp service = logData['service'];
          String serviceRead = logData['serviceRead'];
          String frontrightRead = logData['frontrightRead'];
          String frontleftRead = logData['frontleftRead'];
          String backrightRead = logData['backrightRead'];
          String backleftRead = logData['backleftRead'];

          String frontrightF = 'frontright';
          String frontleftF = 'frontleft';
          String backrightF = 'backright';
          String backleftF = 'backleft';
          String serviceF = 'service';
          String serviceReadF = 'serviceRead';
          String frontrightReadF = 'frontrightRead';
          String frontleftReadF = 'frontleftRead';
          String backrightReadF = 'backrightRead';
          String backleftReadF = 'backleftRead';

          String frontrightTitle = 'Front Right Tyre';
          String frontleftTitle = 'Front Left Tyre';
          String backrightTitle = 'Back Right Tyre';
          String backleftTitle = 'Back left Tyre';
          String serviceTitle = 'Car Service ';
          int localReading = convertToInt(carID);

          return Center(
            child: Container(
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'Current Meter Reading: ${localReading.toString()}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        padding: EdgeInsets.all(10),
                        childAspectRatio: 1.5,
                        children: [
                          _buildCard(
                              frontleftTitle,
                              carID,
                              formatTimestamp(frontleft),
                              frontleftRead,
                              frontleftF,
                              frontleftReadF,
                              context),
                          _buildCard(
                              frontrightTitle,
                              carID,
                              formatTimestamp(frontright),
                              frontrightRead,
                              frontrightF,
                              frontrightReadF,
                              context),
                          _buildCard(
                              frontrightTitle,
                              carID,
                              formatTimestamp(frontright),
                              frontrightRead,
                              frontrightF,
                              frontrightReadF,
                              context),
                          _buildCard(
                              backleftTitle,
                              carID,
                              formatTimestamp(backleft),
                              backleftRead,
                              backleftF,
                              backleftReadF,
                              context),
                          _buildCard(
                            backrightTitle,
                            carID,
                            formatTimestamp(backright),
                            backrightRead,
                            backrightF,
                            backrightReadF,
                            context,
                          ),
                          _buildCard(
                            serviceTitle,
                            carID,
                            formatTimestamp(service),
                            serviceRead,
                            serviceF,
                            serviceReadF,
                            context,
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          );
        },
      ),
    );
  }

  Widget _buildCard(
    String fieldTitle,
    String carID,
    String value,
    String reading,
    String fieldTime,
    String fieldRead,
    BuildContext context,
  ) {
    print(fieldTitle);
    final title = fieldTitle != null ? fieldTitle : "Title";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditReadingScreen(
              careId: carID,
              value: value,
              reading: reading,
              fieldTime: fieldTime,
              fieldRead: fieldRead,
              context: context,
            ),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.directions_car),
              SizedBox(width: 5),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 10),
          Text(
            reading,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          Text(
            'Car Run: ',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
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

  Future<String> getCurrentMeterReading(String carId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('userCar')
          .doc(carId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        String currentMeter = data?["current"] ?? '';
        return currentMeter;
      } else {
        return '0';
      }
    } catch (e) {
      print('Error retrieving current meter reading: $e');
      return '0';
    }
  }

  int convertToInt(String numberString) {
    try {
      return int.parse(numberString);
    } catch (e) {
      return 0; // Return 0 if the conversion fails or the string is empty
    }
  }
}
