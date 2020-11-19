import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:testapp/providers/all_plants.dart';

import 'home.dart';
import 'startup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  User user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: AllPlants(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Green Legacy Test New',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: (user == null) ? SignUp() : Home(uid: user.uid),
      ),
    );
  }
}
