import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:share/share.dart';
import 'package:testapp/widgets/navigate_drawer.dart';
import 'package:timeago/timeago.dart' as timeago;

class News extends StatefulWidget {
  News({this.uid});
  final String uid;
  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> {
  final String title = "News";
  var filePath = '';
  var name = '';
  final startAtTimestamp = Timestamp.fromMillisecondsSinceEpoch(
      DateTime.parse('2019-03-13 16:49:42.044').millisecondsSinceEpoch);

  @override
  void initState() {
    super.initState();
    User user = FirebaseAuth.instance.currentUser;
    name = user.displayName ?? '';
  }

  _ago(Timestamp t) {
    return timeago.format(t.toDate(), locale: 'en_short');
  }

  Future _findPath(String imageUrl) async {
    final cache = DefaultCacheManager();
    final file = await cache.getSingleFile(imageUrl);
    setState(() {
      filePath = file.path;
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
                .collection('News')
                .orderBy('dateTime')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData)
                return Center(
                  child: Text('Welcome ' + name),
                );
              else
                return ListView(
                  children: snapshot.data.docs.map((document) {
                    if (document['imageUrl'] != null) {
                      _findPath(document['imageUrl']);
                      return Card(
                        child: ListTile(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(25),
                                      ),
                                    ),
                                    title: Text(
                                      document['title'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20.0),
                                    ),
                                    content: Scrollbar(
                                      thickness: 2,
                                      radius: Radius.circular(100),
                                      child: SingleChildScrollView(
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                            if (document['imageUrl'] == null)
                                              CircularProgressIndicator(),
                                            Container(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      document['imageUrl'],
                                                  width: 200,
                                                  progressIndicatorBuilder: (context,
                                                          url,
                                                          downloadProgress) =>
                                                      CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                  //fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Text(
                                              'Published by ' +
                                                  document['userName'] +
                                                  " " +
                                                  _ago(document['dateTime']) +
                                                  ' ago',
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 15,
                                                color: Colors.grey,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              child: Text(document['body']),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Column(children: <Widget>[
                                                  IconButton(
                                                    icon: Icon(Icons.share),
                                                    onPressed: () {
                                                      final RenderBox box =
                                                          context
                                                              .findRenderObject();
                                                      Share.shareFiles([
                                                        filePath
                                                      ],
                                                          text: document[
                                                                  'title'] +
                                                              '\n \n' +
                                                              document['body'] +
                                                              '\n \n' +
                                                              "Written by " +
                                                              document[
                                                                  'userName'] +
                                                              '\n \n' +
                                                              '#GreenLegacyApp ',
                                                          subject:
                                                              document['title'],
                                                          sharePositionOrigin:
                                                              box.localToGlobal(
                                                                      Offset
                                                                          .zero) &
                                                                  box.size);
                                                    },
                                                    color: Colors.green,
                                                  ),
                                                  Text(
                                                    "Share",
                                                    textScaleFactor: 0.5,
                                                  ),
                                                ]),
                                                Column(children: <Widget>[
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.close,
                                                      color: Colors.red,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  Text(
                                                    "Close",
                                                    textScaleFactor: 0.5,
                                                  ),
                                                ]),
                                              ],
                                            ),
                                          ])),
                                    ));
                              },
                            );
                          },
                          title: Text(document['title']),
                          subtitle: Text(
                            'Published by ' + document['userName'],
                            overflow: TextOverflow.ellipsis,
                          ),
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
                          trailing: Text(_ago(document['dateTime']) + ' ago'),
                        ),
                      );
                    } else {
                      return Card(
                        child: ListTile(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(25),
                                      ),
                                    ),
                                    title: Text(
                                      document['title'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20.0),
                                    ),
                                    content: SingleChildScrollView(
                                        child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                          Container(
                                            alignment: Alignment.center,
                                            child: Text(document['body']),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Column(children: <Widget>[
                                                IconButton(
                                                  icon: Icon(Icons.share),
                                                  onPressed: () {
                                                    final RenderBox box =
                                                        context
                                                            .findRenderObject();
                                                    Share.share(
                                                        document['title'] +
                                                            '\n \n' +
                                                            document['body'] +
                                                            '\n \n' +
                                                            'Written by ' +
                                                            document[
                                                                'userName'] +
                                                            '\n \n' +
                                                            '#GreenLegacyApp',
                                                        subject:
                                                            document['title'],
                                                        sharePositionOrigin:
                                                            box.localToGlobal(
                                                                    Offset
                                                                        .zero) &
                                                                box.size);
                                                  },
                                                  color: Colors.green,
                                                ),
                                                Text(
                                                  "Share",
                                                  textScaleFactor: 0.5,
                                                ),
                                              ]),
                                              Column(children: <Widget>[
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.close,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                Text(
                                                  "Close",
                                                  textScaleFactor: 0.5,
                                                ),
                                              ]),
                                            ],
                                          ),
                                        ])));
                              },
                            );
                          },
                          title: Text(
                            document['title'],
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle:
                              Text('Published by ' + document['userName']),
                          leading: CircleAvatar(
                            child: Text(
                                document['title'][0].toString().toUpperCase()),
                          ),
                          trailing: Text(_ago(document['dateTime']) + ' ago'),
                        ),
                      );
                    }
                  }).toList(),
                );
            },
          ),
          drawer: NavigateDrawer(uid: widget.uid)),
    );
  }
}
