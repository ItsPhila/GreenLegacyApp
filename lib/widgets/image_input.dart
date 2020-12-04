import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageInput extends StatefulWidget {
  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File _storedImage;

  Future<void> _takePicture() async {
    final imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera, maxWidth: 400, maxHeight: 400);
    setState(() {
      _storedImage = imageFile;
      //_getRef();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
