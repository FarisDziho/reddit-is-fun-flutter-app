import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
void main() {
  runApp(MyApp());
}

class Query {
  String collection = "new";
  String subreddit = "all";
  Query({this.collection,this.subreddit});
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.orange[900],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'reddit'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String collection = "new";
  String subreddit = "";
  Future<List<dynamic>> articles;
  Future<List<dynamic>> PopularSubreddits;
  bool fidgetSpinner=false;


   void _changeCollection(String collection){
     print(collection);
    setState(() {
      this.collection=collection;
      fidgetSpinner=false;
      articles=getArticles();
    });
  }
  void _changeSubreddit(String subreddit){
    setState(() {
      this.subreddit=subreddit;
      fidgetSpinner=false;
      articles=getArticles();
    });
  }

  Future<List<dynamic>> getArticles()async{
    final response =await http.get("https://www.reddit.com/${subreddit.length>0 ? "r/"+subreddit+'/':''}${collection}.json");
    List<dynamic> res =jsonDecode(response.body)['data']['children'];
    fidgetSpinner=true;
    return res;

  }
  Future<List<dynamic>> getPopularSubreddits()async{
    final response =await http.get("https://www.reddit.com/subreddits/popular.json");
    List<dynamic> res =jsonDecode(response.body)['data']['children'];
    return res;

  }

  @override
  void initState(){
    super.initState();
    articles=getArticles();
    PopularSubreddits = getPopularSubreddits();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
       appBar: AppBar(
       ),
        drawer: Drawer(
          child: FutureBuilder(
            future: PopularSubreddits,
            builder: (context,snapshot) {
              if (snapshot.connectionState == ConnectionState.none &&
                  snapshot.hasData == null) {
                return Container();
              }
              if(snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      String title = snapshot.data[index]['data']['display_name'];
                      return ListTile(
                        onTap:(){
                          _changeSubreddit(title);
                          Navigator.of(context).pop();
                          },
                        title: Text(title),
                      );
                      return Text(snapshot.data[index]['data']['title']);
                    });
              }
              else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }

              // By default, show a loading spinner.
              return CircularProgressIndicator();

            }
          ),
        ),
        body:Column(
          children: [
            Navbar(this._changeCollection),
            Expanded(
              child: Padding(
                  padding: EdgeInsets.only(top:10.0),
                child: Scaffold(
                  body: FutureBuilder(
                          future: articles,
                          builder: (context,snapshot) {
                            if(!fidgetSpinner)
                              {
                                return Center(
                                    child:CircularProgressIndicator()
                                );
                              }
                            if (snapshot.connectionState == ConnectionState.none &&
                                snapshot.hasData == null) {
                             /* print('project snapshot data is: ${projectSnap.data}');*//**/
                              return Container();
                            }
                            if (snapshot.hasData)
                            {

                              return ListView.separated(
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                        snapshot.data[index]['data']['title']),
                                    trailing: Image.network(
                                      snapshot.data[index]['data']['thumbnail'],
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace stackTrace) {
                                        return Container();
                                      },
                                    ),
                                  );


                                },
                              separatorBuilder: (context,index){
                                  return Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                  );
                              },
                              );
                            }
                            else if (snapshot.hasError) {
                              return Text("${snapshot.error}");
                            }

                            // By default, show a loading spinner.
                            return CircularProgressIndicator();
                          }
                      )
                  ),
              ),
            )
          ],
        )
    );
  }
}

class Navbar extends StatelessWidget{
  final void Function(String) callback;
  Navbar(this.callback);
  @override
  Widget build(BuildContext context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              child:GestureDetector(
                onTap:(){callback("new");} ,
                child: Column(
                  children: [
                    Icon(
                      Icons.new_releases_outlined,
                      size: 30,
                    ),
                    Text(
                        "new"
                    )
                  ],
                ),
              )
          ),
          Container(
              child:GestureDetector(
                onTap:(){callback("hot");} ,
                child: Column(
                  children: [
                    Icon(
                      Icons.local_fire_department_outlined,
                      size: 30,
                    ),
                    Text(
                        "hot"
                    )
                  ],
                ),
              )
          ),
          Container(
              child:GestureDetector(
                onTap:(){callback("top");} ,
                child: Column(
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 30,
                    ),
                    Text(
                        "Top"
                    )
                  ],
                ),
              )
          ),Container(
              child:GestureDetector(
                onTap:(){callback("rising");} ,
                child: Column(
                  children: [
                    Icon(
                      Icons.trending_up_outlined,
                      size: 30,
                    ),
                    Text(
                        "Rising"
                    )
                  ],
                ),
              )
          )
        ],
      );
    }
  }
