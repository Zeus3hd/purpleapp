import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purple/ohcomponents/item_card.dart';
import 'package:purple/ohmodels/user.dart';
import 'package:purple/ohscreens/create_post.dart';
import 'package:purple/ohscreens/current_user_profile.dart';
import 'package:purple/ohservices/database.dart';
import 'package:purple/ohservices/auth.dart';
import 'package:purple/wrapper.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  String categoryValue;
  String keyword;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return StreamProvider<QuerySnapshot>.value(
      value: DatabaseSerivce(categoryValue: categoryValue, keyword: keyword)
          .thePosts,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => CreatePost()));
          },
          child: Icon(
            Icons.create,
          ),
        ),
        appBar: AppBar(
          actions: <Widget>[
            FlatButton(
                onPressed: () async {
                  if (await _auth.signOut()) {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Wrapper()));
                  }
                },
                child: Text('sign out', style: TextStyle(color: Colors.white))),
            IconButton(
              icon: Icon(
                Icons.person,
                size: 35,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        CurrentUserProfile(userid: user.uid)));
              },
            ),
          ],
          title: Text('Purple'),
          elevation: 7,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  const Color(0xff8E2DE2),
                  const Color(0xff4A00E0)
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<String>(
                        itemHeight: 63,
                        hint: Text('Category'),
                        value: categoryValue,
                        items: <String>['Any', 'Product', 'Service', 'Job']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (_) {
                          if (_ != 'Any') {
                            setState(() {
                              categoryValue = _;
                            });
                          } else {
                            setState(() {
                              categoryValue = null;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search..',
                        ),
                        onChanged: (val) {
                          setState(() {
                            keyword = val;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                flex: 5,
                child: PostsList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PostsList extends StatefulWidget {
  const PostsList({
    Key key,
  }) : super(key: key);

  @override
  _PostsListState createState() => _PostsListState();
}

class _PostsListState extends State<PostsList> {
  @override
  Widget build(BuildContext context) {
    final posts = Provider.of<QuerySnapshot>(context).documents;
    if (posts != null && posts.length > 0) {
      return ListView(
        children: posts
            .map<Widget>((post) => ItemCard(
                  itemData: post.data,
                  itemDocId: post.documentID,
                ))
            .toList(),
      );
    } else {
      return Center(
        child: Text('No Results'),
      );
    }
  }
}
