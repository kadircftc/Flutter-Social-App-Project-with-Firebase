// ignore_for_file: prefer_const_constructors, file_names, unused_local_variable, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/services/authService.dart';
import 'package:socialapp/services/firestoreService.dart';
import 'package:socialapp/services/storageService.dart';

class EditProfile extends StatefulWidget {
  final UserModel? profile;
  const EditProfile({super.key, required this.profile});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String? about;
  String? userName;
  final _formKey = GlobalKey<FormState>();
  File? _selectedPhoto;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          actions: [
            IconButton(
              icon: Icon(
                Icons.check,
                color: Colors.black,
              ),
              onPressed: _save,
            ),
          ],
          leading: IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.black,
              ),
              onPressed: () => Navigator.pop(context)),
          title: Text(
            "Profilini Düzenle",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: ListView(
          children: [
            isLoading ? LinearProgressIndicator() : SizedBox(height: 0.0),
            _profileImage(widget.profile),
            _userDetail(widget.profile)
          ],
        ));
  }

  _profileImage(UserModel? userData) {
    return Padding(
      padding: EdgeInsets.only(top: 15.0, bottom: 20.0),
      child: InkWell(
        onTap: _selectInGallery,
        child: Center(
          child: ClipOval(
            child: SizedBox(
              width: 200.0,
              height: 200.0,
              child: _selectedPhoto == null
                  ? Image.network(
                      userData!.avatar,
                      fit: BoxFit.cover,
                    )
                  : Image.file(_selectedPhoto!, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }

  _selectInGallery() async {
    var image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 600,
        maxWidth: 800,
        imageQuality: 80);

    setState(() {
      _selectedPhoto = (image != null ? File(image.path) : null)!;
    });
  }

  _userDetail(UserModel? userData) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SizedBox(height: 30.0),
            TextFormField(
              initialValue: userData!.name,
              autocorrect: true,
              decoration: InputDecoration(
                labelText: "Kullanıcı Adı:",
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Kullanıcı Adı alanı boş bırakılamaz!";
                } else if (value.trim().length < 5) {
                  return "kullanıcı adı en az 5 karakter olabilir!";
                }
                return null;
              },
              onSaved: (name) {
                setState(() {
                  userName = name;
                });
              },
            ),
            TextFormField(
              initialValue: userData.about,
              autocorrect: true,
              decoration: InputDecoration(
                labelText: "Hakkında:",
              ),
              validator: (value) {
                if (value!.trim().length > 100) {
                  return "Hakkında en çok 100 karakter olabilir!";
                }
                return null;
              },
              onSaved: (newValue) {
                setState(() {
                  about = newValue;
                });
                
              },
            ),
          ],
        ),
      ),
    );
  }

  _save() async {
    String activeUser =
        Provider.of<AuthService>(context, listen: false).activeUserId;
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      _formKey.currentState!.save();

      late String profilePhotoUrl;
      if (_selectedPhoto == null) {
        profilePhotoUrl = widget.profile!.avatar;
      } else {
        if (widget.profile!.avatar.isNotEmpty) {
          StorageService().deleteProfileImage(widget.profile!.avatar);
        }

        profilePhotoUrl =
            await StorageService().profileImageDownload(_selectedPhoto);
      }

      FirestoreService().editUser(
          userId: activeUser,
          about: about,
          userName: userName,
          photoUrl: profilePhotoUrl);
      setState(() {
        isLoading = false;
      });

      Navigator.pop(context);
    }
  }
}
