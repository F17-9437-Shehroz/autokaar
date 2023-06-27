import 'dart:io';

import 'package:autokaar/locationGarage.dart';
import 'package:autokaar/postClass.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'addnewcarIncomp.dart';
import 'car_model.dart';
import 'logjson.dart';

class addGarageScreen extends StatefulWidget {
  @override
  _SelectCarScreenState createState() => _SelectCarScreenState();
}

class _SelectCarScreenState extends State<addGarageScreen> {
  late List<CarModel> carModels = [];
  String? selectedCompany;
  String? selectedModel;
  late Future<String> uploadd;
  late String imageUrln;
  final meterController = TextEditingController();
  final nameController = TextEditingController();
  String selectedModelLOcal = "";
  String selectedCompanyLocal = "";
  LatLng? selectedLocation;


  File? _imageFileshow;
  @override
  void initState() {
    super.initState();
    fetchCarModels();
  }

  Future<void> fetchCarModels() async {
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('carsModels').get();
    List<CarModel> models = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return CarModel(
        id: doc.id,
        companyName: data['companyName'],
        modelName: data['modelName'],
      );
    }).toList();

    setState(() {
      carModels = models;
    });
  }

  List<String> getDistinctCompanies() {
    return carModels.map((model) => model.companyName).toSet().toList();
  }

  List<String> getModelsForCompany(String company) {
    return carModels
        .where((model) => model.companyName == company)
        .map((model) => model.modelName)
        .toList();
  }

  Future<void> _pickImageshow(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFileshow = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.6;
    List<String> companies = getDistinctCompanies();
    List<String> models =
    selectedCompany != null ? getModelsForCompany(selectedCompany!) : [];

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCarScreen()),
          );
        },
        icon: Icon(Icons.directions_car),
        label: Text('Add new Model'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      appBar: AppBar(
        title: Text('Add Garage'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                    hintText: 'Enter Name',
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30))),
                onChanged: (value) {},
              ),

              SizedBox(height: 16.0),


              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: Icon(Icons.photo_library),
                              title: Text('Photo Library'),
                              onTap: () {
                                _pickImageshow(ImageSource.gallery);
                                Navigator.of(context).pop();
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.photo_camera),
                              title: Text('Camera'),
                              onTap: () {
                                _pickImageshow(ImageSource.camera);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[300],
                    image: _imageFileshow != null
                        ? DecorationImage(
                      image: FileImage(_imageFileshow!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: _imageFileshow == null
                      ? Icon(
                    Icons.add_a_photo,
                    size: 70,
                    //50
                    color: Colors.grey[800],
                  )
                      : null,
                ),
              ),
            TextButton(
              onPressed: () async {
                // Open the map picker or map screen
                final LatLng? location = await pickLocationFromMap();
                if (location != null) {
                  setState(() {
                     selectedLocation = location;
                  });
                }


              },
              child: Text('Select Location'),
            ),


              ElevatedButton(
                onPressed: () {
                  if (selectedCompany != null && selectedModel != null) {
                    print('Selected Company: $selectedCompany');
                    print('Selected Model: $selectedModel');
                    uploadcarImage();
                  } else {
                    print('Any Information can not be empty');
                  }
                },
                child: Text('Add Garage'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> uploadcarImage() async {
    final firebaseStorage = FirebaseStorage.instance;
    if (_imageFileshow != null) {
      String postname = const Uuid().v1();
      var snapshot = await firebaseStorage
          .ref()
          .child('carphotos/$postname')
          .putFile(_imageFileshow!);
      var downloadUrl = await snapshot.ref.getDownloadURL();

      FirebaseAuth auth = FirebaseAuth.instance;
      String cuid = auth.currentUser!.uid.toString();
      imageUrln = downloadUrl;
      uploadPost(cuid, imageUrln);
    }
  }

  Future<String> uploadPost(String uid, String imageUrl) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      // String photoUrl =
      //   await StorageMethods().uploadImageToStorage('posts', file, true);
      String carId = const Uuid().v1(); // creates unique id based on time
      Post post = Post(
          carName: nameController.text.toString(),
          uid: uid,
          company: selectedCompanyLocal.toString(),
          urlS: imageUrl,
          region: "PaKistan",
          timestamp: Timestamp.now(),
          currentMeter: meterController.text.toString(),
          carModelname: selectedModelLOcal,
          carID: carId);
      FirebaseFirestore.instance
          .collection('userCar')
          .doc(carId)
          .set(post.toJson());
      res = "success";
      uploadLog(meterController.text.toString(), carId);
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadLog(String meterReading, String carIDM) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      // String photoUrl =
      //   await StorageMethods().uploadImageToStorage('posts', file, true);
      //String carId = const Uuid().v1(); // creates unique id based on time
      carLog logOfCar = carLog(
          frontright: Timestamp.now(),
          frontleft: Timestamp.now(),
          backright: Timestamp.now(),
          backleft: Timestamp.now(),
          service: Timestamp.now(),
          serviceRead: meterReading,
          frontrightRead: meterReading,
          frontleftRead: meterReading,
          backrightRead: meterReading,
          backleftRead: meterReading,
          backleftReadTitle: 'Back Left Tyre',
          backrightReadTitle: 'Back Right Tyre',
          frontleftReadTitle: 'Front Left Tyre',
          frontrightReadTitle: 'Front Right',
          serviceTitle: 'Service');
      FirebaseFirestore.instance
          .collection('carlog')
          .doc(carIDM)
          .set(logOfCar.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Request permission to access location
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    // Retrieve the current position
    return await Geolocator.getCurrentPosition();
  }

  Future<LatLng?> pickLocationFromMap() async {
    final Position? currentLocation = await getCurrentLocation();
    if (currentLocation != null) {
      // Use the current location as the initial position on the map
      final initialCameraPosition = CameraPosition(
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: 16.0,
      );

      // Open the map screen
      final selectedCameraPosition = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(
            initialCameraPosition: initialCameraPosition,
          ),
        ),
      );

      if (selectedCameraPosition != null) {
        return LatLng(
          selectedCameraPosition.target.latitude,
          selectedCameraPosition.target.longitude,
        );
      }
    }

    return null;
  }

}
