import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shope/model/orderModel.dart';
import 'package:shope/network/network.dart';
import 'package:path/path.dart' as path;
import 'package:async/async.dart';

class UploadStruk extends StatefulWidget {
  final OrderModel model;
  UploadStruk(this.model);
  @override
  _UploadStrukState createState() => _UploadStrukState();
}

class _UploadStrukState extends State<UploadStruk> {
  File image;

  gallery() async {
    var _image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      image = _image;
    });
  }

  String nama = "";
  String id = "";
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      nama = preferences.getString("nama");
      id = preferences.getString("id");
    });
  }

  save() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Processing"),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 4,
                  ),
                  Text("Loading...")
                ],
              ),
            ),
          );
        });
    try {
      var stream = http.ByteStream(DelegatingStream.typed(image.openRead()));
      var length = await image.length();
      var url = Uri.parse(NetworkUrl.uploadStruk());
      var request = http.MultipartRequest("POST", url);
      var multipartFile = http.MultipartFile("image", stream, length,
          filename: path.basename(image.path));
      request.fields['userID'] = id;
      request.fields['idBeli'] = widget.model.idBeli;
      request.files.add(multipartFile);

      var response = await request.send();
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
        final data = jsonDecode(value);
        int valueGet = data['value'];
        String message = data['message'];
        if (valueGet == 1) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              "/CheckUser", (Route<dynamic> route) => false);
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Status Upload:"),
                  content: Text(message),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            "/CheckUser", (Route<dynamic> route) => false);
                        setState(() {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              "/CheckUser", (Route<dynamic> route) => false);
                        });
                      },
                      child: Text("Ok"),
                    )
                  ],
                );
              });
        } else {
          Navigator.pop(context);
          print(message);
        }
      });
    } catch (e) {
      debugPrint("Error $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Struk"),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                SizedBox(height: 10.0),
                InkWell(
                    onTap: gallery,
                    child: image == null
                        ? widget.model.struk == 'Struk'
                            ? InkWell(
                                onTap: gallery,
                                child: Container(
                                  height: 200.0,
                                  width: 200.0,
                                  color: Colors.green,
                                  child: Text("Pilih Struk"),
                                ),
                              )
                            : Image.network(
                                NetworkUrl.struk(widget.model.struk),
                                height: 200.0,
                                width: 200.0,
                                fit: BoxFit.contain,
                              )
                        : Image.file(
                            image,
                            fit: BoxFit.fill,
                          )),
                SizedBox(height: 5.0),
                Center(
                  child: Text(widget.model.bank),
                ),
                Container(
                  width: 350,
                  height: 400,
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white),
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Nomor Tagihan"),
                          Text(widget.model.idBeli),
                        ],
                      ),
                      Divider(height: 50),
                      FlatButton(
                          onPressed: save,
                          color: Colors.grey[200],
                          child: Text("Upload")),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
