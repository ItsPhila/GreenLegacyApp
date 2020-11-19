import 'package:flutter/foundation.dart';
import 'package:testapp/models/plant.dart';

class AllPlants with ChangeNotifier {
  List<Plant> _items = [];

  List<Plant> get item {
    return [..._items];
  }

  void addPlant(String userId, String plantId, String title, String imageUrl) {
    final newPlant = Plant(
        userId: userId,
        plantId: plantId,
        //plantId: DateTime.now().toString(),
        imageUrl: imageUrl,
        title: title,
        location: null);
    _items.add(newPlant);
    notifyListeners();
  }
}
