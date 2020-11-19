import 'dart:io';

import 'package:flutter/foundation.dart';

class PlantLocation {
  final double latitude;
  final double longitude;

  PlantLocation({@required this.latitude, @required this.longitude});
}

class Plant {
  final String userId;
  final String plantId;
  final String title;
  final PlantLocation location;
  final String imageUrl;

  Plant(
      {@required this.userId,
      @required this.plantId,
      @required this.title,
      @required this.location,
      @required this.imageUrl});
  factory Plant.fromServerMap(Map data) {
    return Plant(
        userId: data['userId'],
        plantId: data['plantId'],
        title: data['title'],
        location: null,
        imageUrl: data['imageUrl']);
  }
}
