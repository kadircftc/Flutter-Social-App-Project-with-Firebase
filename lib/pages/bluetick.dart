// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class BlueTick extends StatelessWidget {
  const BlueTick({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Ayarlar",
          style: TextStyle(color: Colors.white, fontFamily: 'SF', fontSize: 25),
        ),
        backgroundColor: Colors.black,
      ),
      body: Stack(children: [
        Positioned(
          top: 10,
          left: 30,
          child: Text(
            "Mavi Tik\nalmak için başvurun",
            style:
                TextStyle(color: Colors.white, fontSize: 55, fontFamily: 'SF'),
          ),
        ),
        Positioned(
          left: 250,
          top: MediaQuery.of(context).size.height - 900,
          child: ElevatedButton(
            onPressed: () {},
            child: const Text(
              "Başvur",
              style: TextStyle(fontSize: 30, fontFamily: 'SF'),
            ),
            style: ElevatedButton.styleFrom(minimumSize: Size(80, 50)),
          ),
        )
      ]),
      backgroundColor: Colors.black,
    );
  }
}
