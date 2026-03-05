import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

const String baseUrl =
    "http://localhost/mid_66704466/php_api/";

class EditTouristPage extends StatefulWidget {
  final dynamic tourist;

  const EditTouristPage({super.key, required this.tourist});

  @override
  State<EditTouristPage> createState() => _EditTouristPageState();
}

class _EditTouristPageState extends State<EditTouristPage> {

  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController provinceController;
  late TextEditingController descriptionController;



  XFile? selectedImage;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.tourist['name']);

    addressController =
        TextEditingController(text: widget.tourist['address']);

    provinceController =
        TextEditingController(text: widget.tourist['province']);

    descriptionController =
    TextEditingController(text: widget.tourist['description']);

  }

  ////////////////////////////////////////////////////////////
  // ✅ PICK IMAGE
  ////////////////////////////////////////////////////////////

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = pickedFile;
      });
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ UPDATE PRODUCT + IMAGE
  ////////////////////////////////////////////////////////////

  Future<void> updateTourist() async {
    try {

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${baseUrl}update_tourist_with_image.php"),
      );

      ////////////////////////////////////////////////////////
      // ✅ Fields
      ////////////////////////////////////////////////////////

      request.fields['id'] = widget.tourist['id'].toString();
      request.fields['name'] = nameController.text;
      request.fields['address'] = addressController.text;
      request.fields['province'] = provinceController.text;
      request.fields['description'] = descriptionController.text;
      request.fields['old_image'] = widget.tourist['image'];


      ////////////////////////////////////////////////////////
      // ✅ Image (ถ้ามี)
      ////////////////////////////////////////////////////////

      if (selectedImage != null) {

        if (kIsWeb) {

          final bytes = await selectedImage!.readAsBytes();

          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              bytes,
              filename: selectedImage!.name,
            ),
          );

        } else {

          request.files.add(
            await http.MultipartFile.fromPath(
              'image',
              selectedImage!.path,
            ),
          );
        }
      }

      ////////////////////////////////////////////////////////
      // ✅ Send
      ////////////////////////////////////////////////////////

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      final data = json.decode(responseData);

      if (data["success"] == true) {

        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("แก้ไขเรียบร้อย")),
        );
      }

    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    String imageUrl =
        "${baseUrl}images/${widget.tourist['image']}";

    return Scaffold(
      appBar: AppBar(title: const Text("แก้ไขสถานที่ท่องเที่ยว")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: SingleChildScrollView(
          child: Column(
            children: [

              //////////////////////////////////////////////////
              // 🖼 IMAGE PREVIEW
              //////////////////////////////////////////////////

              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(),
                  ),
                  child: selectedImage == null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported),
                        )
                      : kIsWeb
                          ? Image.network(
                              selectedImage!.path,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(selectedImage!.path),
                              fit: BoxFit.cover,
                            ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "ชื่อ places"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "ที่อยู่"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: provinceController,
                decoration: const InputDecoration(labelText: "จังหวัด"),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "รายละเอียด"),
              ),


              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: updateTourist,
                  child: const Text("บันทึก"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}