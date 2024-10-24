import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePicker extends StatefulWidget {
  const ProfileImagePicker({super.key, required this.onPickImage});

  final void Function(File pickedImage) onPickImage;

  @override
  State<ProfileImagePicker> createState() {
    return _ProfileImagePickerState();
  }
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _pickedImageFile;

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150,);

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });  

    widget.onPickImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey,
        foregroundImage: _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
      ),
      TextButton.icon(onPressed: _pickImage , icon: Icon(Icons.image), label: Text('Add image',
      style: TextStyle(
        color: Theme.of(context).primaryColor,
      ),),)
    ],);
  }
}