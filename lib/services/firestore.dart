import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference plants =
    FirebaseFirestore.instance.collection('Plants');

Future<void> addPlantToFireStore(
  String userId,
  String plantId,
  String title,
  String imageUrl,
  Timestamp dateTime,
) async {
  plants.add({
    'userId': userId,
    'plantId': plantId,
    'title': title,
    'imageUrl': imageUrl,
    'dateTime': dateTime,
  });
  return;
}

Future getPlantList() async {
  List itemsList = [];

  try {
    await plants.get().then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        itemsList.add(element.data);
      });
    });
    return itemsList;
  } catch (e) {
    print(e.toString());
    return null;
  }
}
