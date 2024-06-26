import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hiwetaan/components/context.dart';
import 'package:hiwetaan/screens/Profile/profile.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/utils/size_utils.dart';
import '../create_card/widgets/socialMedia.dart';
import 'image_picker.dart';

class EditCard extends StatefulWidget {
  const EditCard({super.key});

  @override
  EditState createState() {
    return EditState();
  }
}

class EditState extends State<EditCard> {
  imagePicker controller = Get.put(imagePicker());

  final _formKey = GlobalKey<FormState>();
  List<DocumentSnapshot<Map<String, dynamic>>> postsDocs = [];
  bool postsFetched = false;
  DocumentSnapshot<Map<String, dynamic>>? userData;
  Map<String, String> links = {};

  bool editMode = false;

  String editModeImageURL = '';
  String editModeImageURLLogo = '';
  String editModeImageURLPortfilio = '';


  File? selectedImage;
  File? selectedLogo;
  File? selectedPortfolio;

  var selectedImageURL;
  var selectedLogoURL;
  var selectedPortfolioURL;

  var imageURL;
  var logoURL;
  var portfolioURL;


  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 80,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text(
            "",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.camera, color: Colors.amber[800]),
              onPressed: () {
                getImage(ImageSource.camera);
              },
              label: Text("Camera"),
            ),
            TextButton.icon(
              icon: Icon(Icons.image, color: Colors.amber[800]),
              onPressed: () {
                getImage(ImageSource.gallery);
              },
              label: Text("Gallery"),
            ),
          ])
        ],
      ),
    );
  }

  Widget bottomSheetLogo() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 80,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text(
            "",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.camera, color: Colors.amber[800]),
              onPressed: () {
                getLogo(ImageSource.camera);
              },
              label: Text("Camera"),
            ),
            TextButton.icon(
              icon: Icon(Icons.image, color: Colors.amber[800]),
              onPressed: () {
                getLogo(ImageSource.gallery);
              },
              label: Text("Gallery"),
            ),
          ])
        ],
      ),
    );
  }
  void updateLinks(Map<String, String> updatedLinks) {
    setState(() {
      links = updatedLinks;
    });
    print('Updated Links: $links');
  }


  Widget bottomSheetPortfolio() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 80,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text(
            "",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.camera, color: Colors.amber[800]),
              onPressed: () {
                getPortfolio(ImageSource.camera);
              },
              label: Text("Camera"),
            ),
            TextButton.icon(
              icon: Icon(Icons.image, color: Colors.amber[800]),
              onPressed: () {
                getPortfolio(ImageSource.gallery);
              },
              label: Text("Gallery"),
            ),
          ])
        ],
      ),
    );
  }

  Future getImage(ImageSource source) async {
    var image = await ImagePicker.platform
        .getImageFromSource(source: source); //pickImage
    print('printing source of image $source');
    setState(() {
      selectedImage = File(image!.path);
    });
  }

  Future getLogo(ImageSource source) async {
    var image = await ImagePicker.platform
        .getImageFromSource(source: source); //pickImage
    print('printing source of image $source');
    setState(() {
      selectedLogo = File(image!.path);
    });
  }

  Future getPortfolio(ImageSource source) async {
    var image = await ImagePicker.platform
        .getImageFromSource(source: source); //pickImage
    print('printing source of image $source');
    setState(() {
      selectedPortfolio = File(image!.path);
    });
  }

  getPosts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userUID = user.uid;

      await FirebaseFirestore.instance
          .collection('Posts')
          .where('PostedByUID', isEqualTo: userUID)
          .get()
          .then((value) async {
        if (value.docs.isNotEmpty) {
          setState(() {
            postsDocs = value.docs.toList();
            postsFetched = true;
          });
          postsDocs.sort((a, b) =>
              b.data()!['TimeStamp'].compareTo(a.data()!['TimeStamp']));
        }
      });
    }
  }

  var lodaing = true;
  var Prefix ='';
  var FirstName = '';
  var MiddleName ='';
  var LastName = '';
  var Position = '';
  var uniqueUserName = '';
  var sUserName = '';
  var Email = '';
  var PhoneNumber = '';
  var CompanyName ='';
  var nationality = '';
  var city = '';

  void getUserInfo() async {
    var user = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    setState(() {
      uniqueUserName = user.data()!['uniqueUserName'];
    });
  }
  getUserData() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        userData = value;
        sUserName = value['sUserName'];
        nationality = value['sNationality'];
        city = value['sCity'];
        lodaing = false;
        getPosts();
      });
    });
  }

  void getCardInfo() async {
    await FirebaseFirestore.instance
        .collection('Cards')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        FirstName = value.data()!['FirstName'];
        MiddleName = value.data()!['MiddleName'];
        LastName = value.data()!['LastName'];
        imageURL = value.data()!['ImageURL'];
        logoURL = value.data()!['LogoURL'];
        portfolioURL = value.data()!['PortfolioURL'];
        Prefix = value.data()!['Prefix'];
        Position = value.data()!['Position'];
        Email = value.data()!['Email'];
        PhoneNumber = value.data()!['PhoneNumber'];
        CompanyName = value.data()!['CompanyName'];
        links = value.data()!['Links'];
      });
    });
  }



  @override
  void initState() {
    getCardInfo();
    getUserData();
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dynamic myImage = const AssetImage("assets/images/avatary.png");
    // Build a Form widget using the _formKey created above.
    return lodaing
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              SizedBox(height: 10,),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      onChanged: (value) => Prefix = value,
                      controller: TextEditingController(text: Prefix),
                      decoration: InputDecoration(
                        labelText: 'Prefix',
                        border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10))),
                      ),
                      //   autofillHints:,
                      cursorColor: Colors.black,
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      onChanged: (value) => FirstName = value,
                      controller: TextEditingController(text: FirstName),
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10))),
                      ),
                      //   autofillHints:,
                      cursorColor: Colors.black,
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      onChanged: (value) => MiddleName = value,
                      controller: TextEditingController(text: MiddleName),
                      decoration: InputDecoration(
                        labelText: 'Middle Name',
                        border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10))),
                      ),
                      //   autofillHints:,
                      cursorColor: Colors.black,
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      onChanged: (value) => LastName = value,
                      controller: TextEditingController(text: LastName),
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10))),
                      ),
                      //   autofillHints:,
                      cursorColor: Colors.black,
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      onChanged: (value) => Position = value,
                      controller: TextEditingController(text: Position),
                      decoration: const InputDecoration(
                        labelText: 'Position',
                        //  hintText: 'name',
                        border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10))),
                      ),
                      //   autofillHints:,
                      cursorColor: Colors.black,
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      onChanged: (value) => CompanyName = value,
                      controller: TextEditingController(text: CompanyName),
                      decoration: const InputDecoration(
                        label: Text("CompanyName"),
                        border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10))),
                      ),
                      cursorColor: Colors.black,
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      onChanged: (value) => Email = value,
                      controller: TextEditingController(text: Email),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        // hintText: 'name',
                        border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10))),
                      ),
                      //   autofillHints:,
                      cursorColor: Colors.black,
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      onChanged: (value) => PhoneNumber = value,
                      controller: TextEditingController(text: PhoneNumber),
                      decoration: const InputDecoration(
                        label: Text("Phone Number"),
                        border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10))),
                      ),
                      //   autofillHints:,
                      cursorColor: Colors.black,
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Choose links to edit',
                style: GoogleFonts.robotoCondensed(
                    fontSize: 25, fontWeight: FontWeight.bold),
              ),

              SocialMedia(
                saved: links,
                paddin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
              ),
              Padding(
                padding: getPadding(
                  top: 16,
                  // right: 74,
                ),
              ),
              SizedBox(height: 10),
              Visibility(
                visible: editMode,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    image: DecorationImage(
                      image: NetworkImage(editModeImageURL),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                replacement: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: ((builder) => bottomSheet()),
                    );
                  },
                  child: selectedImage != null
                      ? Container(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                      : Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: selectedImage != null
                          ? Image.file(
                        selectedImage!,
                        height: 150,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      )
                          : Image.network(
                        imageURL ?? '',
                        height: 150,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Visibility(
                      visible: editMode,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          image: DecorationImage(
                            image: NetworkImage(editModeImageURLLogo),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      replacement: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: ((builder) => bottomSheetLogo()),
                          );
                        },
                        child: selectedLogo != null
                            ? Container(
                          height: 150,
                          width: 150,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(
                              selectedLogo!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                            : Container(
                          height: 170,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: selectedLogo != null
                                ? Image.file(
                              selectedLogo!,
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            )
                                : Image.network(
                              logoURL ?? '',
                              height: 170,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Visibility(
                      visible: editMode,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          image: DecorationImage(
                            image: NetworkImage(editModeImageURLPortfilio),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      replacement: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: ((builder) => bottomSheetPortfolio()),
                          );
                        },
                        child: selectedPortfolio != null
                            ? Container(
                          height: 150,
                          width: 150,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(
                              selectedPortfolio!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                            : Container(
                          height: 170,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: selectedPortfolio != null
                                ? Image.file(
                              selectedPortfolio!,
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            )
                                : Image.network(
                              portfolioURL ?? '',

                              height: 170,
                              width: 170,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: 20,
              ),
              //update card data
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Check if any image is selected
                    if (selectedImage != null || selectedLogo != null || selectedPortfolio != null) {
                      // Upload images to Firebase Storage and get their URLs
                      if (selectedImage != null) {
                        final imageRef = FirebaseStorage.instance.ref().child('images').child('user_image.jpg');
                        final uploadTask = imageRef.putFile(selectedImage!);
                        final snapshot = await uploadTask.whenComplete(() => null);
                        imageURL = await snapshot.ref.getDownloadURL();
                      }

                      if (selectedLogo != null) {
                        final logoRef = FirebaseStorage.instance.ref().child('images').child('user_logo.jpg');
                        final uploadTask = logoRef.putFile(selectedLogo!);
                        final snapshot = await uploadTask.whenComplete(() => null);
                        logoURL = await snapshot.ref.getDownloadURL();
                      }

                      if (selectedPortfolio != null) {
                        final portfolioRef = FirebaseStorage.instance.ref().child('images').child('user_portfolio.jpg');
                        final uploadTask = portfolioRef.putFile(selectedPortfolio!);
                        final snapshot = await uploadTask.whenComplete(() => null);
                        portfolioURL = await snapshot.ref.getDownloadURL();
                      }
                    }

                    // Fetch existing card data from Firestore
                    DocumentSnapshot<Map<String, dynamic>> cardSnapshot = await FirebaseFirestore.instance
                        .collection('Cards')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .get();

                    // Extract existing card data
                    Map<String, dynamic> existingData = cardSnapshot.data() ?? {};

                    // Merge updated links with existing data
                    Map<String, dynamic> updatedData = {
                      ...existingData, // Spread existing data
                      'Prefix': Prefix,
                      'FirstName': FirstName,
                      'MiddleName': MiddleName,
                      'LastName': LastName,
                      'Position': Position,
                      'CompanyName': CompanyName,
                      'Email': Email,
                      'PhoneNumber': PhoneNumber,
                      'Links': links, // Update links in Firestore
                      // Include other fields to update here...
                      'ImageURL': imageURL, // Update imageURL
                      'LogoURL': logoURL,   // Update logoURL
                      'PortfolioURL': portfolioURL, // Update portfolioURL
                    };

                    // Update user's card information in Firestore
                    await FirebaseFirestore.instance
                        .collection('Cards')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update(updatedData);

                    // Show a snackbar to indicate successful save
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Your card information has been saved successfully'),
                        backgroundColor: Color.fromARGB(255, 149, 181, 236),
                      ),
                    );

                    // Navigate back to profile page
                    context.pushPage(profiletest());
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(5),
                  backgroundColor: const Color.fromARGB(255, 2, 84, 86),
                  fixedSize: const Size(150, 40),
                  elevation: 0,
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              )





            ]
    )));

  }
}
/// update links
/// images not changes with latest updates (logo and portfolio)