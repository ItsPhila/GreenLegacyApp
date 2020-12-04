import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference users =
    FirebaseFirestore.instance.collection('Users');

Future<void> addUserToFireStore(
    String userId,
    String email,
    String name,
    String role,
    // String imageUrl,
    Timestamp dateTime,
    String region) async {
  users.add({
    'userId': userId,
    'email': email,
    'name': name,
    'role': role,
    // 'imageUrl': imageUrl,
    'dateTime': dateTime,
    'region': region,
  });
  return;
}

Future getUserList() async {
  List itemsList = [];

  try {
    await users.get().then((querySnapshot) {
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
