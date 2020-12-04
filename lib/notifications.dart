import 'package:flutter/material.dart';
import 'package:testapp/widgets/navigate_drawer.dart';

class Notifications extends StatefulWidget {
  Notifications({this.uid});
  final String uid;
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final String title = "Notifications";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: Text('Hey'),
          drawer: NavigateDrawer(uid: widget.uid)),
    );
  }
}
