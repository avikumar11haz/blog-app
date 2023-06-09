import 'package:blog_app/screens/add_post.dart';
import 'package:blog_app/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final dbRef = FirebaseDatabase.instance.ref().child('Posts');
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController searchController = TextEditingController();
  String search = "";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Color(0xfff9fafc),
        appBar: AppBar(
          title: Text('New Blogs'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> AddPostScreen()));
              },
                child: Icon(Icons.add)),
            SizedBox(width: 15,),
            InkWell(
                onTap: (){
                  auth.signOut().then((value){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
                  });

                },
                child: Icon(Icons.logout)),
            SizedBox(width: 20,)
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            children: [
              TextFormField(
                controller: searchController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    hintText: 'Search with blog title',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder()
                ),
                onChanged: (String value){
                  setState(() {
                    search = value;
                  });
                },

              ),
              Expanded(
                child: FirebaseAnimatedList(
                  query: dbRef.child('Post List'),
                  itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index){
                    dynamic item = snapshot.value;

                    String tempTitle = item['pTitle'];
                    if(searchController.text.isEmpty){
                      return SizeTransition(
                        sizeFactor: animation,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: FadeInImage.assetNetwork(
                                      fit: BoxFit.cover,
                                      width: MediaQuery.of(context).size.width * 1,
                                      height: MediaQuery.of(context).size.height * .25,
                                      placeholder: 'images/blogpost.jpg',
                                      image: item['pImage']),
                                ),
                                SizedBox(height: 10,),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(item['pTitle'], style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                ),
                                SizedBox(height: 5,),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(item['pDescription'], style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }else if(tempTitle.toLowerCase().contains(searchController.text.toString())){
                      return SizeTransition(
                        sizeFactor: animation,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: FadeInImage.assetNetwork(
                                      fit: BoxFit.cover,
                                      width: MediaQuery.of(context).size.width * 1,
                                      height: MediaQuery.of(context).size.height * .25,
                                      placeholder: 'images/blogpost.jpg',
                                      image: item['pImage']),
                                ),
                                SizedBox(height: 10,),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(item['pTitle'], style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                ),
                                SizedBox(height: 5,),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(item['pDescription'], style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }else{
                      return Container();
                    }

                  },
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}
