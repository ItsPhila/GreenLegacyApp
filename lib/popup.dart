import 'package:barcode_scan_fix/barcode_scan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

import 'package:provider/provider.dart';
import 'package:testapp/providers/all_plants.dart';
import 'package:testapp/services/firestore.dart';

class PopUp extends StatefulWidget {
  @override
  _PopUpState createState() => _PopUpState();
}

class _PopUpState extends State<PopUp> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  File _storedImage;
  final _titleController = TextEditingController();
  String qrResult = 'id + ', qrResultErr;
  var id = '';
  DateTime _dateTime;
  String latitude;
  String longitude;
  String imageUrl;

  FlutterLocalNotificationsPlugin notification;

  @override
  void initState() {
    super.initState();
    var androidInitialize = new AndroidInitializationSettings('app_icon');
    var initializationSettings =
        new InitializationSettings(android: androidInitialize);
    notification = new FlutterLocalNotificationsPlugin();
    notification.initialize(initializationSettings,
        onSelectNotification: notificationSelected);
    User user = FirebaseAuth.instance.currentUser;
    id = user.uid ?? '';
    // getCurrentLocation();
  }

  Future _showNotification() async {
    var androidDetails = new AndroidNotificationDetails(
        "Channel ID", "name", "description",
        importance: Importance.max);
    var generalNotificationDetals =
        new NotificationDetails(android: androidDetails);
    // await notification.show(0, 'title', 'body', generalNotificationDetals,
    //     payload: "Task");
    //var scheduledTime = DateTime.now().add(Duration(seconds: 5));

    notification.schedule(1, "title", "body",
        _dateTime.add(Duration(seconds: 5)), generalNotificationDetals);
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.qrResult = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.qrResultErr = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.qrResultErr = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.qrResultErr =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.qrResultErr = 'Unknown error: $e');
    }
  }

  void _addPlantInfo() async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('plant_image')
        .child(id + qrResult + '.jpg');
    await ref.putFile(_storedImage).onComplete;
    final plantImageUrl = await ref.getDownloadURL();

    // setState(() {
    //   _firebaseAuth.currentUser.updateProfile(photoURL: url);
    // });
  }

  Future<void> _takePicture() async {
    final imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera, maxWidth: 400, maxHeight: 400);
    setState(() {
      _storedImage = imageFile;
      _getRef();
    });
  }

  void _getRef() async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('plant_image')
        .child(qrResult + id + '.jpg');
    await ref.putFile(_storedImage).onComplete;
    final url = await ref.getDownloadURL();

    setState(() {
      //_firebaseAuth.currentUser.updateProfile(photoURL: url);
      imageUrl = url;
    });
  }

  void _getCurrentLocation() async {
    final geoposition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      latitude = '${geoposition.latitude}';
      longitude = '${geoposition.longitude}';
    });
  }

  void _savePlant() {
    DateTime currentPhoneDate = DateTime.now();
    Timestamp timeStamp = Timestamp.fromDate(currentPhoneDate);

    addPlantToFireStore(
        id, qrResult, _titleController.text, imageUrl, timeStamp);
    // Provider.of<AllPlants>(context, listen: false)
    //     .addPlant(qrResult, id ,_titleController.text, imageUrl);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(25),
        ),
      ),
      title: Text(
        'Add Plant Info',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25.0),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              //Image.asset('assets/images/listening.gif'),
              SizedBox(height: 10.0),
              Container(
                alignment: Alignment.center,
                height: 45.0,
                child: TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter title';
                    }
                    return null;
                  },
                  controller: _titleController,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: 'Enter plant name'),
                ),
              ),
              //SizedBox(height: 30.0),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(children: <Widget>[
                    if (qrResult != null && qrResultErr == null)
                      IconButton(
                        icon: Icon(Icons.done),
                        onPressed: () => scan(),
                        color: Colors.green,
                      )
                    else
                      (IconButton(
                        icon: Icon(Icons.qr_code_scanner_sharp),
                        onPressed: () => scan(),
                      )),
                    Text(
                      "QR Code ID",
                      textScaleFactor: 0.5,
                    ),
                  ]),
                  Column(children: <Widget>[
                    if (_storedImage != null && qrResult != null)
                      IconButton(
                        icon: Icon(Icons.done),
                        onPressed: _takePicture,
                        color: Colors.green,
                      )
                    else if (qrResult != null)
                      IconButton(
                        icon: Icon(Icons.add_a_photo_sharp),
                        onPressed: _takePicture,
                      )
                    else
                      IconButton(
                        icon: Icon(Icons.add_a_photo_sharp),
                        color: Colors.grey,
                        onPressed: () {},
                      ),
                    Text(
                      "Picture",
                      textScaleFactor: 0.5,
                    ),
                  ]),
                  Column(children: <Widget>[
                    if (latitude != null || longitude != null)
                      IconButton(
                        icon: Icon(Icons.done),
                        color: Colors.green,
                        onPressed: _getCurrentLocation,
                      )
                    else
                      IconButton(
                        icon: Icon(Icons.add_location_alt_sharp),
                        onPressed: _getCurrentLocation,
                      ),
                    Text(
                      "Location",
                      textScaleFactor: 0.5,
                    ),
                  ]),
                  Column(children: <Widget>[
                    if (_dateTime != null)
                      IconButton(
                        color: Colors.green,
                        icon: Icon(Icons.done),
                        onPressed: () {
                          showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2099))
                              .then((date) {
                            setState(() {
                              _dateTime = date;
                            });
                          });
                        },
                      )
                    else
                      IconButton(
                        icon: Icon(Icons.add_alarm_sharp),
                        onPressed: () {
                          showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2099))
                              .then((date) {
                            setState(() {
                              _dateTime = date;
                            });
                          });
                        },
                      ),
                    Text(
                      "Reminder",
                      textScaleFactor: 0.5,
                    ),
                  ]),
                ],
              ),
              SizedBox(height: 20),
              Column(
                children: <Widget>[
                  if (_titleController != null &&
                      qrResult != null &&
                      _storedImage != null)
                    StreamBuilder(builder:
                        (BuildContext _context, AsyncSnapshot _snapshot) {
                      if (imageUrl == null)
                        return Center(child: CircularProgressIndicator());
                      else
                        return Center(
                            child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Text("Add"),
                          onPressed: () {
                            if (_formKey.currentState.validate()) _savePlant();
                          },
                          color: Colors.green,
                          textColor: Colors.white,
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          splashColor: Colors.blueGrey,
                        ));
                    })
                  else
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text("Add"),
                      onPressed: _savePlant,

                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      splashColor: Colors.blueGrey,
                    )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future notificationSelected(String payload) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text('Notification Clicked $payload'),
            ));
  }
}
