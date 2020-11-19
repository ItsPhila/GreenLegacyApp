import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testapp/providers/all_plants.dart';
import 'package:testapp/services/firestore.dart';

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

  List plantList = [];

  @override
  void initState() {
    super.initState();
    User user = FirebaseAuth.instance.currentUser;
    name = user.displayName ?? '';
    fetchPlantList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        // body: Text('Hey'),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('Plants').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData == false || snapshot.data == null)
              return Center(
                child: Text('Welcome ' + name),
              );
            else
              return ListView(
                children: snapshot.data.docs.map((document) {
                  return Card(
                    child: ListTile(
                      title: Text(document['title']),
                      subtitle: Text('ID: ' + document['plantId']),
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(document['imageUrl']),
                      ),
                      trailing: Text(''),
                    ),
                  );
                }).toList(),
              );
          },
        ),

        // body: Container(
        //   child: ListView.builder(
        //       itemCount: plantList.length,
        //       itemBuilder: (ctx, i) {
        //         return Card(
        //           child: ListTile(
        //             title: Text(plantList[i]["title"]),
        //             subtitle: Text(plantList[i]["userId"]),
        //             leading: CircleAvatar(
        //               backgroundImage: NetworkImage(plantList[i]["imageUrl"]),
        //             ),
        //             trailing: Text(''),
        //           ),
        //         );
        //       }),
        // )

        // body: Consumer<AllPlants>(
        //   child: Center(
        //     child: Text('Welcome ' + name),
        //   ),
        //   builder: (ctx, allPlants, ch) => allPlants.item.length <= 0
        //       ? ch
        //       : ListView.builder(
        //           itemCount: allPlants.item.length,
        //           itemBuilder: (ctx, i) => Column(children: <Widget>[
        //             SizedBox(
        //               height: 10,
        //             ),
        //             if (allPlants.item[i].imageUrl != null)
        //               ListTile(
        //                 leading: CircleAvatar(
        //                   backgroundImage:
        //                       NetworkImage(allPlants.item[i].imageUrl),
        //                   // radius: 100,
        //                 ),
        //                 title: Text(allPlants.item[i].title),
        //                 onTap: () {},
        //               )
        //             else
        //               ListTile(
        //                 leading: CircleAvatar(
        //                   child: Text(allPlants.item[i].title[0].toUpperCase()),
        //                   // radius: 100,
        //                 ),
        //                 title: Text(allPlants.item[i].title),
        //                 onTap: () {},
        //               )
        //           ]),
        //         ),
        // ),

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
        drawer: NavigateDrawer(uid: widget.uid));
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
