import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final formkey = new GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  TextEditingController _descriptionController = new TextEditingController();
  late String url;
  late XFile sampleImage;

  Future getImage() async {
    XFile? tempImage = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      sampleImage = tempImage!;
    });
  }

  void _showSuccessfulmessage(String msg) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("From Startup Projects"),
              content: Text(msg),
              actions: <Widget>[
                // ignore: deprecated_member_use
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Okay"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Upload"),
      ),
      body: Center(
        child: Form(
          key: formkey,
          child: Column(
            children: [
              SizedBox(
                height: 45,
              ),
              ElevatedButton(onPressed: getImage, child: Text("+ Pick Image")),
              SizedBox(
                height: 14,
              ),
              Padding(
                  padding: EdgeInsets.all(20),
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(hintText: "Enter Description"),
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        return "Enter description";
                      }
                      return null;
                    },
                  )),
              Padding(padding: EdgeInsets.all(10)),
              // ignore: deprecated_member_use
              RaisedButton(
                onPressed: () async {
                  final postImageRef =
                      FirebaseStorage.instance.ref().child("Images");
                  var timekey = DateTime.now();
                  if (!formkey.currentState!.validate()) {
                    return;
                  }
                  formkey.currentState!.save();
                  String message = "Image Uploaded Successfully";
                  UploadTask uploadTask = postImageRef
                      .child(timekey.toString() + ".jpg")
                      .putFile(File(sampleImage.path));
                  var dowurl = await (await uploadTask).ref.getDownloadURL();
                  url = dowurl.toString();
                  print(url);
                  Map<String, dynamic> data = {
                    "imageurl": url,
                    "description": _descriptionController.text
                  };
                  FirebaseFirestore.instance
                      .collection("Images")
                      .add(data)
                      .then((value) => _showSuccessfulmessage(message));
                },
                child: Text("Submit"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
