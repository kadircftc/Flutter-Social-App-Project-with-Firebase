// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, prefer_is_empty, avoid_init_to_null, prefer_final_fields

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/pages/profile.dart';
import 'package:socialapp/services/firestoreService.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();

  Future<List<UserModel>>? _aramaSonucu = null;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        setState(() {
          _aramaSonucu = null;
        });
      } else {
        setState(() {
          _aramaSonucu = FirestoreService().searchUser(_searchController.text);
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _createAppBar(),
      body: _aramaSonucu != null ? getResult() : noSearch(),
    );
  }

  AppBar _createAppBar() {
    return AppBar(
      titleSpacing: 0.0,
      backgroundColor: Colors.grey[100],
      title: TextFormField(
        controller: _searchController,
        decoration: InputDecoration(
            hintText: "Kullanıcı Ara...",
            prefixIcon: const Icon(Icons.search),
            border: InputBorder.none,
            fillColor: Colors.white,
            filled: true,
            suffixIcon: IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _aramaSonucu = null;
                });
              },
              icon: const Icon(
                Icons.clear,
              ),
            ),
            contentPadding: const EdgeInsets.only(top: 16.0)),
      ),
    );
  }

  noSearch() {
    return Center(
      child: Text("Kullanıcı Ara"),
    );
  }

  getResult() {
    return FutureBuilder<List<UserModel>>(
      future: _aramaSonucu,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.data!.length == 0) {
          return Center(
            child: Text("Böyle bir kullanıcı bulunamadı!"),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            UserModel? user = snapshot.data?[index];
            return userIndex(user!);
          },
        );
      },
    );
  }

  userIndex(UserModel user) {
    return Column(
      children: [
        Container(
          height: 50,
          width: double.infinity,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) =>
                          ProfilePage(profileOwnerId: user.id)));
            },
            child: ListTile(
              leading: CircleAvatar(
                  backgroundImage: user.avatar.isNotEmpty
                      ? NetworkImage(user.avatar)
                      : AssetImage("assets/images/noProfile.png")
                          as ImageProvider),
              title: Text(
                user.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Divider(),
      ],
    );
  }
}
