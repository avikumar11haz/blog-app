import 'dart:io';

import 'package:blog_app/components/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_database/firebase_database.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {

  bool showSpinner = false;
  final postRef = FirebaseDatabase.instance.ref().child('Posts');
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  File? _image;
  final picker = ImagePicker();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Future getImageGallery()async{
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if(pickedFile != null){
        _image = File(pickedFile.path);
      }else{
        print('no image selected');
      }
    });
  }

  Future getCameraImage()async{
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if(pickedFile != null){
        _image = File(pickedFile.path);
      }else{
        print('no image selected');
      }
    });
  }

  void dialog(context){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            ),
            content: Container(
              height: 120,
              child: Column(
                children: [
                  InkWell(
                    onTap: (){
                      getCameraImage();
                      Navigator.pop(context);
                    },
                    child: ListTile(
                      leading: Icon(Icons.camera),
                      title: Text('Camera'),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      getImageGallery();
                      Navigator.pop(context);
                    },
                    child: ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('Gallery'),
                    ),
                  )
                ],
              ),
            ),
        );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Upload Blogs'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
            child: Column(
              children: [
                InkWell(
                  onTap: (){
                    dialog(context);
                  },
                  child: Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height * .2,
                      width: MediaQuery.of(context).size.width * 1,
                      child: _image != null? ClipRect(
                        child: Image.file(
                          _image!.absolute,
                          width: 100,
                          height: 100,
                          fit: BoxFit.fill,
                        ),
                      ):Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10)),
                        width: 100,
                        height: 100,
                        child: Icon(Icons.camera_alt, color: Colors.blue,),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                Form(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: titleController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          hintText: 'Enter post title',
                          border: OutlineInputBorder(),
                          hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                          labelStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal)
                        ),
                      ),
                      SizedBox(height: 30,),
                      TextFormField(
                        controller: descriptionController,
                        keyboardType: TextInputType.text,
                        minLines: 1,
                        maxLines: 5,
                        decoration: InputDecoration(
                            labelText: 'Description',
                            hintText: 'Enter post description',
                            border: OutlineInputBorder(),
                            hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                            labelStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal)
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30,),
                RoundButton(title: 'Upload', onPress: ()async{
                  setState(() {
                    showSpinner = true;
                  });

                  try{
                    int date = DateTime.now().millisecondsSinceEpoch;
                    firebase_storage.Reference refe = firebase_storage.FirebaseStorage.instance.ref('/blogapp$date');
                    UploadTask uploadTask = refe.putFile(_image!.absolute);
                    await Future.value(uploadTask);
                    var newUrl = await refe.getDownloadURL();

                    final User? user = _auth.currentUser;
                    postRef.child('Post List').child(date.toString()).set({

                      'pId' : date.toString(),
                      'pImage': newUrl.toString(),
                      'pTime': date.toString(),
                      'pTitle': titleController.text.toString(),
                      'pDescription': descriptionController.text.toString(),
                      'uEmail': user!.email.toString(),
                      'uid': user!.uid.toString()

                        }).then((value){
                          toastMessage('Post Published');
                          setState(() {
                            showSpinner = false;
                          });
                          Navigator.pop(context); //add for testing
                    }).onError((error, stackTrace){
                      toastMessage(error.toString());
                      setState(() {
                        showSpinner = false;
                      });
                    });
                  }catch(e){
                    setState(() {
                      showSpinner = false;
                    });
                    toastMessage(e.toString());
                  }

                })
              ],
            ),
          ),
        ),
      ),
    );
  }
  void toastMessage(String message){
    Fluttertoast.showToast(
        msg: message.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black ,
        fontSize: 16.0
    );
  }
}
