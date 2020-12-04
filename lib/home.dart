import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testapp/services/firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'popup.dart';
import 'widgets/navigate_drawer.dart';

class Home extends StatefulWidget {
  Home({this.uid});
  final String uid;
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String title = "Home";
  var name = '';
  var userId = '';
  var circleTime = '';

  List plantList = [];

  @override
  void initState() {
    super.initState();
    fetchPlantList();

    User user = FirebaseAuth.instance.currentUser;
    name = user.displayName ?? '';
    userId = user.uid ?? '';
  }

  _ago(Timestamp t) {
    return timeago.format(t.toDate(), locale: 'en_short');
  }

  fetchPlantList() async {
    dynamic results = await getPlantList();

    if (results == null) {
      print('Unable to retrieve');
    } else {
      setState(() {
        plantList = results;
      });
    }
  }

  circle() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      circleTime = '2';
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          // body: Text('Hey'),
          body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Plants')
                .orderBy('dateTime')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.data.docs.isEmpty)
                return Center(
                  child: Text('Welcome ' + name + '!'),
                );
              else
                return ListView(
                  children: snapshot.data.docs.map((document) {
                    if (document['userId'] == userId)
                      return Card(
                        child: ListTile(
                          title: Text(document['title']),
                          subtitle: Text(
                              'Planted ' + _ago(document['dateTime']) + ' ago'),
                          // leading: CircleAvatar(
                          //   backgroundImage: NetworkImage(document['imageUrl']),
                          // ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              imageUrl: document['imageUrl'],
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      CircularProgressIndicator(
                                          value: downloadProgress.progress),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                          trailing: Text(''),
                        ),
                      );
                    else {
                      //return Center(child: Text('No Plants!'));
                      return null;
                    }
                  }).toList(),
                );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return PopUp();
                },
              );
            },
            tooltip: 'Add Plant',
            child: Icon(Icons.add),
          ),
          drawer: NavigateDrawer(uid: widget.uid)),
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text(title),
//         ),
//         body: ChangeNotifierProvider.value(
//           value: AllPlants(),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 //Text('Welcome ' + name),
//                 Consumer<AllPlants>(builder: (child: Center(child: Text('Hello'),),ctx, allPlants, ch) => allPlants.item.length <= 0 ? ch : ListView(),),
//               ],
//             ),
//           ),
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return PopUp();
//               },
//             );
//           },
//           tooltip: 'Add Plant',
//           child: Icon(Icons.add),
//         ),
//         drawer: NavigateDrawer(uid: widget.uid));
//   }
// }
