// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/pages/flow.dart';
import 'package:socialapp/pages/notifications.dart';
import 'package:socialapp/pages/profile.dart';
import 'package:socialapp/pages/search.dart';
import 'package:socialapp/pages/upload.dart';
import 'package:socialapp/services/authService.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _activePage = 0;

  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String activeUserId =
        Provider.of<AuthService>(context, listen: false).activeUserId;

    return Scaffold(
      body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (value) {
            setState(() {
              _activePage = value;
            });
          },
          controller: pageController,
          children: [
            const FlowPage(),
            const SearchPage(),
            const UploadPage(),
            const NotificationsPage(),
            ProfilePage(
              profileOwnerId: activeUserId,
            )
          ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _activePage,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(color: Colors.amber),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Akış"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Keşfet"),
          BottomNavigationBarItem(
              icon: Icon(Icons.file_upload), label: "Yükle"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Bildirimler"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
        onTap: (selectedPageNo) {
          setState(() {
            pageController.jumpToPage(selectedPageNo);
          });
        },
      ),
    );
  }
}
