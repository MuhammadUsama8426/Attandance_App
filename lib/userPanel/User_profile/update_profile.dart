import 'dart:io';

import 'package:attandance_app/widget/Appcolor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final String id = FirebaseAuth.instance.currentUser!.uid;

  File? _imagefile;
  final ImagePicker imagePicker = ImagePicker();
  bool _loading = false;

  void _validate() {
    if (_imagefile == null && _nameController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please add an image');
    } else if (_imagefile == null) {
      Fluttertoast.showToast(msg: 'Please add an image');
    } else if (_nameController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please add a name');
    } else {
      setState(() {
        _loading = true;
      });
      _uploadImage();
    }
  }

  void _uploadImage() {
    String imageFileName = DateTime.now().microsecondsSinceEpoch.toString();
    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child("profileimages")
        .child(imageFileName);
    final UploadTask uploadTask = storageReference.putFile(_imagefile!);

    uploadTask.then((TaskSnapshot taskSnapshot) {
      taskSnapshot.ref.getDownloadURL().then((imageUrl) {
        postDetailsToFirestore(imageUrl);
      });
    }).catchError((onError) {
      setState(() {
        _loading = false;
      });
      Fluttertoast.showToast(msg: onError.toString());
    });
  }
  // void _uploadimage() {
  //   String imagefilename = DateTime.now().microsecondsSinceEpoch.toString();
  //   final Reference storageReference = FirebaseStorage.instance
  //       .ref()
  //       .child("profileimages")
  //       .child(imagefilename);
  //   final UploadTask uploadTask = storageReference.putFile(_imagefile!);
  //   uploadTask.then((TaskSnapshot taskSnapshot) {
  //     taskSnapshot.ref.getDownloadURL().then((imageurl) {
  //       postDetailsToFirestore(imageurl);
  //     });
  //   }).catchError((onError) {
  //     setState(() {
  //       _loading = false;
  //     });
  //     Fluttertoast.showToast(
  //       msg: onError.toString(),
  //     );
  //     print(
  //       onError.toString(),
  //     );
  //   });
  // }

  Future<void> postDetailsToFirestore(String imageUrl) async {
    final String name = _nameController.text;
    if (name.isNotEmpty) {
      Map<String, dynamic> data = {
        "id": id,
        "fullName": name,
        'profilepic': imageUrl,
      };
      await userCollection
          .doc(id)
          .update(data)
          .whenComplete(() => print("Profile Updated"))
          .catchError((e) => print(e));

      _nameController.clear();
      Navigator.of(context).pop();
    }
  }

  Future<void> _chooseImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Image Source"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo),
                title: Text("Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imagefile = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Update Profile",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: AppColors.Appbacground,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _imagefile == null
                  ? Container(
                      width: double.infinity,
                      height: 250.0,
                      color: Colors.lightBlueAccent,
                      child: MaterialButton(
                        onPressed: _chooseImage,
                        child: Text("Choose Image",
                            style: TextStyle(fontSize: 16.0)),
                      ),
                    )
                  : GestureDetector(
                      onTap: _chooseImage,
                      child: Container(
                        width: double.infinity,
                        height: 250.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(_imagefile!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue,
                child: MaterialButton(
                  minWidth: MediaQuery.of(context).size.width,
                  onPressed: () async {
                    _validate();
                    setState(() {
                      _loading = false;
                    });
                  },
                  child: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.red,
                            strokeWidth: 1.5,
                          ),
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



























// import 'dart:io';

// import 'package:attandance_app/widget/Appcolor.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_picker/image_picker.dart';
// class Update_profile extends StatefulWidget {
//   const Update_profile({Key? key}) : super(key: key);

//   @override
//   State<Update_profile> createState() => _Update_profileState();
// }

// class _Update_profileState extends State<Update_profile> {
//   final _auth = FirebaseAuth.instance;
//   final  TextEditingController _nameController = TextEditingController();
//   final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
//   String id=FirebaseAuth.instance.currentUser!.uid;

//   File? _imagefile;
//   ImagePicker imagePicker= ImagePicker();
//   bool _loading =false;
//   void _validate(){
//     if(_imagefile==null && _nameController.text.isEmpty){
//       Fluttertoast.showToast(msg: 'please add image ');
//     }else if(_imagefile==null){
//       Fluttertoast.showToast(msg: 'please add image');
//     }
//     else if(_nameController.text.isEmpty){
//       Fluttertoast.showToast(msg: 'please add name');
//     }
//     else{
//       setState(() {
//         _loading=true;
//       });
//       _uploadimage();

//     }

//   }
//   void _uploadimage(){

//     String  _imagefilename = DateTime.now().microsecondsSinceEpoch.toString();
//     final Reference storageReference = FirebaseStorage.instance.ref().child("profileimages").child(_imagefilename);
//     final UploadTask uploadTask= storageReference.putFile(_imagefile!);
//     uploadTask.then((TaskSnapshot taskSnapshot) {
//       taskSnapshot.ref.getDownloadURL().then((imageurl) {

//         postDetailsToFirestore(imageurl);

//       });

//     }).catchError((onError){
//       setState(() {
//         _loading=false;
//       });
//       Fluttertoast.showToast(msg: onError.toString(),
//       );
//       print(onError.toString(),);

//     });

//   }
//   postDetailsToFirestore(String imageurl) async {
//     final String name = _nameController.text;
//     //final double? price = double.tryParse(_priceController.text);
//     if (name != null) {
//       Map<String, dynamic> data = <String, dynamic>{
//         "id":id,
//         "fullName": name,
//         'profilepic': imageurl,
//       };
//       await userCollection.doc(id)
//           .update(data)
//           .whenComplete(() => print("profile Update"))
//           .catchError((e) => print(e));

//       _nameController.text = '';

//       Navigator.of(context).pop();
//     }
//   }

//   Future<void> _choose_image() async{
//     // ignore: deprecated_member_use
//     PickedFile? pickedFile= await imagePicker.getImage(source: ImageSource.gallery);

//     setState(() {
//       _imagefile = File(pickedFile!.path);
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Update profile",
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//         backgroundColor: AppColors.Appbacground,
//         elevation: 0,
//         centerTitle: true,
//         leading: const BackButton(
//           color: Colors.white,
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               _imagefile== null? Container(
//                 width: double.infinity,
//                 height: 250.0,
//                 color: Colors.lightBlueAccent,
//                 child: MaterialButton(
//                   child: Text("Choose image",style: TextStyle(fontSize: 16.0),),

//                   onPressed: () {
//                     _choose_image();
//                   },

//                 ),
//               ):GestureDetector(
//                 onTap: (){
//                   _choose_image();
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   height: 250.0,
//                   decoration: BoxDecoration(
//                       image: DecorationImage(
//                           image: FileImage(_imagefile!),fit: BoxFit.cover
//                       )
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16.0,),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: TextField(
//                   controller: _nameController,
//                   keyboardType: TextInputType.text,
//                   decoration: InputDecoration(
//                     labelText: 'Name',
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16.0,),

//               Material(
//                 elevation:  5,
//                 borderRadius: BorderRadius.circular(10),
//                 color: Colors.blue,
//                 child: MaterialButton(
//                   minWidth: MediaQuery.of(context).size.width,
//                   // style: ElevatedButton.styleFrom(shape: StadiumBorder()),
//                   onPressed: () async {
//                     _validate();
//                     setState(() {
//                       _loading = false;
//                     });
//                   },
//                   child: (_loading)
//                       ? const SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         color: Colors.red,
//                         strokeWidth: 1.5,
//                       ))
//                       : const Text('Submit', style: TextStyle(
//                       fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
