// ignore_for_file: sized_box_for_whitespace, prefer_final_fields, unused_field, prefer_const_constructors, avoid_function_literals_in_foreach_calls, non_constant_identifier_names, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socialapp/models/post.dart';
import 'package:socialapp/models/user.dart';
import 'package:socialapp/pages/bluetick.dart';
import 'package:socialapp/pages/editProfile.dart';
import 'package:socialapp/pages/singlePost.dart';
import 'package:socialapp/services/authService.dart';
import 'package:socialapp/services/firestoreService.dart';
import 'package:socialapp/widgets/postCart.dart';

class ProfilePage extends StatefulWidget {
  final String profileOwnerId;
  const ProfilePage({
    super.key,
    required this.profileOwnerId,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _post = 0;
  int _follower = 0;
  int _follow = 0;
  UserModel? _profilSahibi;
  List<Post> _posts = [];
  String liste = "list";
  late String _activeuser;
  bool isFollow = false;
  bool isSwitched = false;
  bool isFollowBack = false;

  Future<void> followerGet() async {
    int followercount =
        await FirestoreService().followerCount(widget.profileOwnerId);
    if (mounted) {
      setState(() {
        _follower = followercount;
      });
    }
  }

  followGet() async {
    int followCount =
        await FirestoreService().followCount(widget.profileOwnerId);
    if (mounted) {
      setState(() {
        _follow = followCount;
      });
    }
  }

  _getPosts() async {
    List<Post> posts = await FirestoreService().getPosts(widget.profileOwnerId);
    if (mounted) {
      setState(() {
        _posts = posts;
        _post = _posts.length;
      });
    }
  }

  Widget viewPosts(UserModel userData) {
    if (liste == "list") {
      if (isFollow == true || widget.profileOwnerId == _activeuser) {
        return ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              return PostCard(
                post: _posts[index],
                user: userData,
              );
            });
      } else {
        return Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.xmark_shield_fill,
                    color: !isSwitched ? Colors.black : Colors.white,
                  ),
                  Text(
                    "Bu kullanıcının profili gizli",
                    style: TextStyle(
                        color: !isSwitched ? Colors.black : Colors.white,
                        fontFamily: 'SF',
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                "Gönderilerini görmek istiyorsanız takip isteği gönderin!",
                style: TextStyle(
                    color: !isSwitched ? Colors.black : Colors.white,
                    fontFamily: 'SF',
                    fontSize: 17,
                    fontWeight: FontWeight.normal),
              )
            ],
          ),
        );
      }
    } else {
      List<GridTile> tiles = [];
      _posts.forEach((post) {
        tiles.add(
          _createTile(post),
        );
      });

      return GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0,
          childAspectRatio: 1.0,
          physics: NeverScrollableScrollPhysics(),
          children: tiles);
    }
  }

  GridTile _createTile(Post post) {
    return GridTile(
        child: GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    SinglePost(postId: post.id, postOwnerId: post.postedId)));
      },
      child: Hero(
        tag: "post_${post.id}",
        child: Image.network(
          post.postImageUrl,
          fit: BoxFit.cover,
        ),
      ),
    ));
  }

  _FollowExist() async {
    bool userIsFollow = await FirestoreService().isFollowExists(
        profileOwnerId: widget.profileOwnerId, activeUserId: _activeuser);
    if (mounted) {
      setState(() {
        isFollow = userIsFollow;
      });
    }
  }

  _followBackExist() async {
    bool userIsFollowBack = await FirestoreService().isFollowBack(
        profileOwnerId: widget.profileOwnerId, activeUserId: _activeuser);
    if (mounted) {
      setState(() {
        isFollowBack = userIsFollowBack;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    followerGet();
    followGet();
    _getPosts();
    _activeuser = Provider.of<AuthService>(context, listen: false).activeUserId;
    _FollowExist();
    _followBackExist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isSwitched ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 5,
        title: const Text(
          "Profil",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          widget.profileOwnerId == _activeuser
              ? IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => BlueTick(),
                      ),
                    );
                  },
                  icon: Icon(CupertinoIcons.settings))
              : SizedBox(
                  height: 0.0,
                ),
          /*Switch(
            activeColor: Colors.black,
            value: isSwitched,
            onChanged: (value) {
              setState(() {
                isSwitched = value;
              });
            },
          ),*/
          widget.profileOwnerId == _activeuser
              ? IconButton(
                  onPressed: logOut,
                  icon: const Icon(
                    Icons.exit_to_app,
                    color: Colors.black,
                  ))
              : SizedBox(
                  height: 0.0,
                )
        ],
      ),
      body: FutureBuilder<UserModel?>(
          future: FirestoreService().getUserById(widget.profileOwnerId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            _profilSahibi = snapshot.data;

            return ListView(
              children: [
                profileDetail(snapshot.data),
                isFollow || widget.profileOwnerId == _activeuser
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                liste = "list";
                              });
                            },
                            icon: Icon(liste == "list"
                                ? CupertinoIcons.square_list_fill
                                : CupertinoIcons.square_list),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                liste = "grid";
                              });
                            },
                            icon: Icon(liste == "grid"
                                ? CupertinoIcons.square_grid_2x2_fill
                                : CupertinoIcons.square_grid_2x2),
                          )
                        ],
                      )
                    : SizedBox(
                        height: 0.0,
                      ),
                Divider(
                  color: !isSwitched ? Colors.grey[500] : Colors.white,
                ),
                viewPosts(snapshot.data!)
              ],
            );
          }),
    );
  }

  Widget profileDetail(UserModel? profileData) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: profileData!.avatar.isNotEmpty
                    ? NetworkImage(profileData.avatar)
                    : const AssetImage("assets/images/noProfile.png")
                        as ImageProvider,
                backgroundColor: Colors.grey,
                radius: 50,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    socialCalculator(header: "Gönderiler", number: _post),
                    socialCalculator(header: "Takipçi", number: _follower),
                    socialCalculator(header: "Takip", number: _follow),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Row(
            children: [
              !isSwitched
                  ? Text(
                      profileData.name,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    )
                  : Text(
                      profileData.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
              Container(
                height: 20,
                width: 20,
                child: Image.network(
                  fit: BoxFit.cover,
                  "https://w7.pngwing.com/pngs/626/893/png-transparent-blue-and-white-check-logo-facebook-social-media-verified-badge-logo-vanity-url-blue-checkmark-blue-angle-text-thumbnail.png",
                  scale: 0.5,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 5.0,
          ),
          !isSwitched
              ? Text(profileData.about)
              : Text(
                  profileData.about,
                  style: TextStyle(color: Colors.white),
                ),
          const SizedBox(
            height: 25.0,
          ),
          widget.profileOwnerId == _activeuser
              ? _editProfile()
              : !isFollow
                  ? _followUserButton()
                  : _unfollowUser()
        ],
      ),
    );
  }

  Widget _editProfile() {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditProfile(profile: _profilSahibi)));
          },
          child: const Text(
            "Profili Düzenle",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15.0),
          )),
    );
  }

  Widget _followUserButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          onPressed: () {
            FirestoreService().followUser(widget.profileOwnerId, _activeuser);
            if (mounted) {
              setState(() {
                isFollow = true;
              });
            }
            followerGet();
            followGet();
          },
          child: isFollowBack
              ? const Text(
                  "Sen De Takip Et",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0),
                )
              : Text(
                  "Takip Et",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0),
                )),
    );
  }

  Widget _unfollowUser() {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
          onPressed: () {
            FirestoreService().unfollowUser(widget.profileOwnerId, _activeuser);
            if (mounted) {
              setState(() {
                isFollow = false;
              });
            }
            followerGet();
            followGet();
          },
          child: const Text(
            "Takipten Çık",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15.0),
          )),
    );
  }

  Widget socialCalculator({String header = "", int number = 0}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          number.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 2.0,
        ),
        Text(
          header,
          style: const TextStyle(fontSize: 15.0),
        ),
      ],
    );
  }

  void logOut() {
    Provider.of<AuthService>(context, listen: false).logOut();
  }
}
