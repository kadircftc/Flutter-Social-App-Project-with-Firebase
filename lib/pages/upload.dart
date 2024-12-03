// ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/services/authService.dart';
import 'package:socialapp/services/firestoreService.dart';
import 'package:socialapp/services/storageService.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  late File file;
  late bool fileNull = true;
  bool isLoading = false;

  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return fileNull ? uploadButton() : postForm();
  }

  Widget uploadButton() {
    return IconButton(
        onPressed: () {
          selectPhoto();
        },
        icon: const Icon(
          Icons.file_upload,
          size: 50.0,
        ));
  }

  Widget postForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          "Gönderi Oluştur",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: IconButton(
            onPressed: () {
              setState(() {
                fileNull = true;
              });
            },
            icon: Icon(
              Icons.close,
              color: Colors.black,
            )),
        actions: [
          IconButton(
            onPressed: _createPost,
            icon: Icon(Icons.send),
            color: Colors.black,
          )
        ],
      ),
      body: ListView(
        children: [
          isLoading
              ? LinearProgressIndicator()
              : SizedBox(
                  height: 0.0,
                ),
          AspectRatio(
            aspectRatio: 16.0 / 9.0,
            child: Image.file(
              file,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(
                labelText: "Açıklama Ekle",
                contentPadding: EdgeInsets.only(left: 15, right: 15)),
          ),
          TextFormField(
            controller: locationController,
            decoration: InputDecoration(
                labelText: "Konum Ekle",
                contentPadding: EdgeInsets.only(left: 15, right: 15)),
          ),
        ],
      ),
    );
  }

  void _createPost() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      String imageUrl = await StorageService().postImageDownload(file);

      String activeUserId =
          Provider.of<AuthService>(context, listen: false).activeUserId;

      await FirestoreService().createPost(
          createdUserId: activeUserId,
          postImageUrl: imageUrl,
          description: descriptionController.text,
          location: locationController.text);
    }

    setState(() {
      isLoading = false;
      descriptionController.clear();
      locationController.clear();
      fileNull = true;
    });
  }

  selectPhoto() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text("Gönderi Oluştur"),
            children: [
              SimpleDialogOption(
                child: Text("Fotoğraf Çek"),
                onPressed: () {
                  takePhoto();
                },
              ),
              SimpleDialogOption(
                child: Text("Galeriden Yükle"),
                onPressed: () {
                  selectInGallery();
                  Navigator.pop(context);
                },
              ),
              SimpleDialogOption(
                child: Text("iptal"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  takePhoto() async {
    var image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxHeight: 600,
        maxWidth: 800,
        imageQuality: 80);

    setState(() {
      file = (image != null ? File(image.path) : null)!;
      fileNull = false;
    });
  }

  selectInGallery() async {
    var image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 600,
        maxWidth: 800,
        imageQuality: 100);

    setState(() {
      file = (image != null ? File(image.path) : null)!;
      fileNull = false;
    });
  }
}
