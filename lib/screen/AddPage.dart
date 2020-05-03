import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddPage extends StatefulWidget {
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _title = new TextEditingController();
  TextEditingController _price = new TextEditingController();
  TextEditingController _quantity = new TextEditingController();

  bool _isLoading = false;

  File _image;
  Future getImageFromGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  _storeData() async{
    if(_formKey.currentState.validate()){
      StorageReference reference = FirebaseStorage.instance.ref().child("images/"+DateTime.now().millisecondsSinceEpoch.toString());
      StorageUploadTask uploadTask = reference.putFile(_image);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      String imageLink = await taskSnapshot.ref.getDownloadURL();

      Firestore.instance.collection("grocery").add({
        'title': _title.text,
        'price': _price.text,
        'quantity': _quantity.text,
        'image': imageLink
      }).then((value) => Navigator.pop(context)).catchError((error){
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add Grocery",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Theme(
            data: ThemeData(
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                ),
                filled: true,
                fillColor: Colors.white70,
                labelStyle: TextStyle(
                  color: Colors.black54,
                  fontSize: 16.0,
                ),
              ),
            ),
            child: Container(
              margin: EdgeInsets.fromLTRB(22.0, 48.0, 22.0, 48.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    GestureDetector(
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          border: Border(
                            top: BorderSide(color: Colors.blueGrey),
                            left: BorderSide(color: Colors.blueGrey),
                            bottom: BorderSide(color: Colors.blueGrey),
                            right: BorderSide(color: Colors.blueGrey),
                          ),
                        ),
                        child: _image == null ? Center(
                          child: Icon(Icons.image,),
                        ) : Image(
                          image: FileImage(_image),
                          fit: BoxFit.cover,
                        ),
                      ),
                      onTap: (){
                        getImageFromGallery();
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    TextFormField(
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: "Product Name",
                      ),
                      keyboardType: TextInputType.text,
                      controller: _title,
                      enabled: !_isLoading,
                      validator: (value) {
                        if(value.isEmpty) return "Title";
                        return null;
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    TextFormField(
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: "Product Price",
                      ),
                      keyboardType: TextInputType.number,
                      controller: _price,
                      enabled: !_isLoading,
                      validator: (value) {
                        if(value.isEmpty) return "Price";
                        return null;
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    TextFormField(
                      autofocus: false,
                      decoration: InputDecoration(
                        hintText: "Product Quantity (eg. 1 Kg)",
                      ),
                      keyboardType: TextInputType.emailAddress,
                      controller: _quantity,
                      enabled: !_isLoading,
                      validator: (value) {
                        if(value.isEmpty) return "Quantity";
                        return null;
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0))
                        ),
                        child: Text("Save",style: TextStyle(color: Colors.white),),
                        color: _isLoading ? Colors.grey : Colors.blue,
                        onPressed: (){
                          if(_isLoading) return null;
                          setState(() {
                            _isLoading = true;
                          });
                          _storeData();
                        },
                      ),
                    )
                  ]
              ),
            ),
          ),
        ),
      ),
    );
  }
}
