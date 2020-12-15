import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:testapp/main.dart';

import 'widgets/navigate_drawer.dart';
import 'dart:io';

class Settings extends StatefulWidget {
  Settings({this.uid});
  final String uid;

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _formKey = GlobalKey<FormState>();
  GlobalKey<RefreshIndicatorState> refreshKey;
  TextEditingController emailUpdateController = TextEditingController();
  TextEditingController nameUpdateController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final String title = "Settings";
  var name = '';
  var email = '';
  var id = '';
  bool isObscure;
  File _pickedImage;

  void _pickImage() async {
    final pickedImageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 100, maxWidth: 150);
    setState(() {
      _pickedImage = pickedImageFile;
      //_firebaseAuth.currentUser.updateProfile(photoURL: _pickedImage);
      _getRef();
    });
  }

  void _getRef() async {
    final ref =
        FirebaseStorage.instance.ref().child('user_image').child(id + '.jpg');
    await ref.putFile(_pickedImage).onComplete;
    final url = await ref.getDownloadURL();

    setState(() {
      _firebaseAuth.currentUser.updateProfile(photoURL: url);
    });
  }

  @override
  void initState() {
    super.initState();
    User user = FirebaseAuth.instance.currentUser;
    name = user.displayName ?? '';
    email = user.email ?? '';
    id = user.uid ?? '';
    refreshKey = GlobalKey<RefreshIndicatorState>();
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 1));
    initState();
    return null;
  }

  getProfileImage() {
    if (_firebaseAuth.currentUser.photoURL != null) {
      return Image.network(
        _firebaseAuth.currentUser.photoURL,
        height: 100,
        width: 100,
        fit: BoxFit.cover,
      );
    } else {
      return Text(
        name[0].toUpperCase(),
        style: TextStyle(fontSize: 40),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: RefreshIndicator(
          key: refreshKey,
          onRefresh: () async {
            await refreshList();
          },
          child: ListView(
            children: [
              SingleChildScrollView(
                child: Column(children: <Widget>[
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(children: <Widget>[
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.green.shade400,
                              child: CircleAvatar(
                                radius: 47,
                                backgroundColor: Colors.green,
                                backgroundImage: _pickedImage != null
                                    ? FileImage(_pickedImage)
                                    : null,
                                child: (_pickedImage != null)
                                    ? null
                                    : ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(200.0),
                                        child: getProfileImage(),
                                      ),
                              ),
                            ),
                            IconButton(
                                icon: Icon(Icons.add_a_photo),
                                onPressed: _pickImage)
                          ]),
                        ),
                        // SizedBox(
                        //   height: 20,
                        // ),
                      ],
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text(name),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Change Name'),
                                  content: TextField(
                                    autofocus: true,
                                    controller: nameUpdateController,
                                    decoration: InputDecoration(
                                        hintText: "Enter New Name..."),
                                  ),
                                  actions: [
                                    new FlatButton(
                                      onPressed: () {
                                        setState(() {
                                          this
                                              ._firebaseAuth
                                              .currentUser
                                              .updateProfile(
                                                  displayName:
                                                      nameUpdateController.text
                                                          .trim());
                                        });
                                        name = nameUpdateController.text;
                                        Navigator.of(context).pop();
                                      },
                                      child: new Text('Submit'),
                                    ),
                                    new FlatButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: new Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    )
                                  ],
                                );
                              },
                              context: context);
                        },
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.email),
                      title: Text(email),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Change Email Address'),
                                  content: Form(
                                    key: _formKey,
                                    child: TextFormField(
                                      keyboardType: TextInputType.emailAddress,
                                      autofocus: true,
                                      controller: emailUpdateController,
                                      decoration: InputDecoration(
                                          hintText: "Enter New Email..."),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Enter an Email Address';
                                        } else if (!value.contains('@') ||
                                            !value.contains('.')) {
                                          return 'Please enter a valid email address';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  actions: [
                                    new FlatButton(
                                      onPressed: () {
                                        if (_formKey.currentState.validate()) {
                                          setState(() {
                                            this
                                                ._firebaseAuth
                                                .currentUser
                                                .updateEmail(
                                                    emailUpdateController.text
                                                        .trim());
                                          });
                                          email = emailUpdateController.text;
                                          Navigator.of(context).pop();
                                        }
                                      },
                                      child: new Text('Submit'),
                                    ),
                                    new FlatButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: new Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    )
                                  ],
                                );
                              },
                              context: context);
                        },
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.lock),
                      title: Text(
                        isObscure != false
                            ? name
                            : '${name.replaceAll(RegExp(r"."), "*")}',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
        drawer: NavigateDrawer(uid: widget.uid));
  }
}
