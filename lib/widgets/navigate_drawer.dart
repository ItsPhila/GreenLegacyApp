import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../settings.dart';
import '../home.dart';
import '../main.dart';

class NavigateDrawer extends StatefulWidget {
  final String uid;
  NavigateDrawer({Key key, this.uid}) : super(key: key);
  @override
  _NavigateDrawerState createState() => _NavigateDrawerState();
}

class _NavigateDrawerState extends State<NavigateDrawer> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final String title = "Green Legacy App";
  var name = 'User';

  @override
  void initState() {
    super.initState();
    User user = FirebaseAuth.instance.currentUser;
    name = user.displayName ?? '';
  }

  getProfileImage() {
    if (_firebaseAuth.currentUser.photoURL != null) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: Colors.green.shade400,
        child: CircleAvatar(
          radius: 37,
          backgroundColor: Colors.green,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(200.0),
            child: Image.network(
              _firebaseAuth.currentUser.photoURL,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else if (name != null) {
      // return Icon(
      //   Icons.account_circle,
      //   color: Colors.green.shade400,
      //   size: 100,
      // );
      return CircleAvatar(
        radius: 40,
        backgroundColor: Colors.green.shade400,
        child: CircleAvatar(
          radius: 35,
          backgroundColor: Colors.green,
          child: Text(
            name[0].toUpperCase(),
            style: TextStyle(fontSize: 40),
          ),
        ),
      );
    } else {
      return CircleAvatar(
        radius: 40,
        backgroundColor: Colors.green.shade400,
        child: CircleAvatar(
          radius: 35,
          backgroundColor: Colors.green,
          child: Text(
            "G",
            //name[0].toUpperCase(),
            style: TextStyle(fontSize: 40),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          Container(
            decoration: new BoxDecoration(
                image: new DecorationImage(
              image: new AssetImage('assets/images/nav_background.png'),
              fit: BoxFit.cover,
            )),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Settings(uid: widget.uid)),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    // child: Icon(
                    //   Icons.account_circle,
                    //   color: Colors.blue.shade400,
                    //   size: 80,
                    // ),
                    child: getProfileImage(),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ' ' +
                          name[0].toUpperCase() +
                          name.substring(1).toLowerCase(),
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Icon(Icons.eco, color: Theme.of(context).accentColor),
                        Text(' 45'),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Divider(
            color: Colors.grey,
            height: 10,
          ),
          ListTile(
            leading: new IconButton(
              icon: new Icon(Icons.home, color: Colors.black),
              highlightColor: Colors.white,
              splashColor: Colors.white,
              onPressed: () => null,
            ),
            title: Text('Home'),
            onTap: () {
              print(widget.uid);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home(uid: widget.uid)),
              );
            },
          ),
          ListTile(
            leading: new IconButton(
              icon: new Icon(Icons.notifications_active, color: Colors.black),
              highlightColor: Colors.white,
              splashColor: Colors.white,
              onPressed: () => null,
            ),
            title: Text('Notifications'),
            onTap: () {
              print(widget.uid);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home(uid: widget.uid)),
              );
            },
          ),
          ListTile(
            leading: new IconButton(
              icon: new Icon(Icons.new_releases, color: Colors.black),
              highlightColor: Colors.white,
              splashColor: Colors.white,
              onPressed: () => null,
            ),
            title: Text('News'),
            onTap: () {
              print(widget.uid);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home(uid: widget.uid)),
              );
            },
          ),
          ListTile(
            leading: new IconButton(
              highlightColor: Colors.white,
              splashColor: Colors.white,
              icon: new Icon(Icons.settings, color: Colors.black),
              onPressed: () => null,
            ),
            title: Text('Settings'),
            onTap: () {
              //print(widget.uid);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Settings(uid: widget.uid)),
              );
            },
          ),
          ListTile(
            leading: new IconButton(
              highlightColor: Colors.white,
              splashColor: Colors.white,
              icon: new Icon(Icons.exit_to_app, color: Colors.black),
              onPressed: () => null,
            ),
            title: Text('Sign Out'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
              );
            },
          ),
        ],
      ),
    );
  }
}
