import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
class HomePage extends StatefulWidget
{
  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  bool loading = true;
  late File _image;
  List _output=[];
  final imagepicker = ImagePicker();


  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {});
    });
  }
  detectimage(File image) async {
    //Text("prediction");
    var prediction = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 7,
        threshold: 0.7,
        imageMean: 127.5,
        imageStd: 127.5);

      setState(() {
      _output = prediction!;
      //Text(" ");
      loading = false;
    });
   // print(prediction);
  }

  loadmodel() async {
    await Tflite.loadModel(
        model: 'assets/model.tflite', labels: 'assets/labels.txt');
  }

  @override
  void dispose() {
    super.dispose();
  }
  pickimage_camera() async {
    var image = await imagepicker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detectimage(_image);
  }

  pickimage_gallery() async {
    var image = await imagepicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
      detectimage(_image);
    }

  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Lead Disease Detector'),
      ),
      body:
      Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          image: DecorationImage(
            image:AssetImage('assets/home.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 150),
            Container(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(

                        child: Text('Capture'),
                        onPressed: () {
                          pickimage_camera();
                        }),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                        child: Text('Gallery'),
                        onPressed: () {
                          pickimage_gallery();

                        }),
                  ),
                ],
              ),
            ),
            Text(" "),
            loading != true
                ? Container(
              child: Column(

                children: [

                  Container(

                    height: 220,
                     width: double.infinity,
                    child: Image.file(_image),
                  ),

                  SizedBox(height: 10),
                  _output.isNotEmpty && _output[0]['label'] != null
                      ? Text(_output[0]['label'].toString())
                      : Column(
                        children: [
                          Text('Error'),
                          Text('Output length: ${_output.length}'),
                          Text('Output: $_output'),
                        ],
                     ),
                ],
              ),
            )
                : Container()
          ],
        ),
      ),
    );
  }
}
