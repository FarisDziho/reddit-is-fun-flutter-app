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
  Future getArticles;
  /*void _changeParams(Query params) {
    setState(() {
      this.searchParams = params;
    });
  }*/
   void _changeCollection(String collection){
     print(collection);
    setState(() {
      this.collection=collection;
      getArticles=pozovi();
    });
  }
  void _changeSubreddit(String subreddit){
    setState(() {
      this.subreddit=subreddit;
    });
  }

  Future<List<dynamic>> pozovi()async{

    final response =await http.get("https://www.reddit.com/${subreddit.length>0 ? "r/"+subreddit:''}${collection}.json");
    List<dynamic> res =jsonDecode(response.body)['data']['children'];
   /* res.forEach((element) {
      print(element['data']['title']);
    });*/
    return res;

  }

  @override
  void initState(){
    print("heloo");
    super.initState();
    getArticles=pozovi();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
       appBar: AppBar(
       ),
        drawer: Drawer(

        ),
        body:Column(
          children: [
            Navbar(this._changeCollection),
            Expanded(
              child: Scaffold(
                body: FutureBuilder(

                        future: getArticles,
                        builder: (context,snapshot) {
                          if (snapshot.connectionState == ConnectionState.none &&
                              snapshot.hasData == null) {
                            /*print('project snapshot data is: ${projectSnap.data}');*/
                            return Container();
                          }
                          if (snapshot.hasData)
                          {

                            return ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                print(snapshot.data[index]['data']['title']);
                                return Text(snapshot.data[index]['data']['title']);

                              });
                          }
                          else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }

                          // By default, show a loading spinner.
                          return CircularProgressIndicator();
                        }
                    )
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
