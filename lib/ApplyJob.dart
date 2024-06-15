import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mind_mingle/Comps/text_field.dart';
import 'package:mind_mingle/Comps/Uihelper.dart';
import 'package:mind_mingle/Comps/SignUp.dart';
import 'package:mind_mingle/Comps/JobDetailssplash.dart';

class ApplyJobPage extends StatefulWidget {
  final Map<String, dynamic> jobData;

  const ApplyJobPage({Key? key, required this.jobData}) : super(key: key);

  @override
  State<ApplyJobPage> createState() => _ApplyJobPageState();
}

class _ApplyJobPageState extends State<ApplyJobPage> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<String> uploadPdf(String fileName, File file) async {
    final reference =
    FirebaseStorage.instance.ref().child("Resume/$fileName.pdf");
    final uploadTask = reference.putFile(file);
    await uploadTask.whenComplete(() {});
    final downloadLink = await reference.getDownloadURL();
    return downloadLink;
  }

  void pickFile() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (pickedFile != null) {
      String fileName = pickedFile.files[0].name;
      File file = File(pickedFile.files[0].path!);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Uploading document..."),
                ],
              ),
            ),
          );
        },
      );

      final downloadLink = await uploadPdf(fileName, file);

      await _firebaseFirestore
          .collection("Job Data")
          .doc(widget.jobData["Job title"])
          .delete();

      // Add the submitted resume to Firestore
      await _firebaseFirestore.collection("Resumes").add({
        "Name": fileName,
        "link": downloadLink,
      });

      Navigator.pop(context); // Close the dialog
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => JobSplash()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Job Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    widget.jobData["Job title"],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Center(
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(width: 2, color: Colors.black),
                            boxShadow: const [BoxShadow(blurRadius: 5.0)],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
                            child: Text(
                              "Job Description: ${widget.jobData["Job Description"]}",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black),
                            ),
                          ))),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Center(
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(width: 2, color: Colors.black),
                            boxShadow: const [BoxShadow(blurRadius: 5.0)],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              "Eligibility: ${widget.jobData["Eligibility"]}",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black),
                            ),
                          ))),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Center(
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(width: 2, color: Colors.black),
                            boxShadow: const [BoxShadow(blurRadius: 5.0)],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              "Salary: ${widget.jobData["Salary and Perks"]}",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black),
                            ),
                          ))),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Center(
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(width: 2, color: Colors.black),
                            boxShadow: const [BoxShadow(blurRadius: 5.0)],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              "Type of Job: ${widget.jobData["Type of job"]}",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black),
                            ),
                          ))),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Uihelper.CustomIconButton(() {
                  pickFile();
                }, "Submit Resume ", Icons.co2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
