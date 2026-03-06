import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'add_tourist_page.dart';
import 'edit_tourist_page.dart';

void main() => runApp(const MyApp());

//////////////////////////////////////////////////////////////
// ✅ CONFIG (แก้ตรงนี้ถ้าเปลี่ยนเครื่อง)
//////////////////////////////////////////////////////////////

const String baseUrl =
    "http://localhost/mid_66705396/php_api/";

//////////////////////////////////////////////////////////////
// ✅ APP ROOT
//////////////////////////////////////////////////////////////

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PlacesList(),
      debugShowCheckedModeBanner: false,
    );
  }
}

//////////////////////////////////////////////////////////////
// ✅ places LIST PAGE
//////////////////////////////////////////////////////////////

class PlacesList extends StatefulWidget {
  const PlacesList({super.key});

  @override
  State<PlacesList> createState() => _PlacesListState();
}

class _PlacesListState extends State<PlacesList> {
  List places = [];
  List filteredplaces = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchplaces();
  }

  ////////////////////////////////////////////////////////////
  // ✅ FETCH DATA
  ////////////////////////////////////////////////////////////

  Future<void> fetchplaces() async {
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}show_data.php"),
      );

      if (response.statusCode == 200) {
        setState(() {
          places = json.decode(response.body);
          filteredplaces = places;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ SEARCH
  ////////////////////////////////////////////////////////////

  void filterplaces(String query) {
    setState(() {
      filteredplaces = places.where((places) {
        final name = places['name']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }




 ////////////////////////////////////////////////////////////
  // ✅ DELETE
  ////////////////////////////////////////////////////////////

  Future<void> deleteplaces(int id) async {
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}delete_tourist.php?id=$id"),
      );

      final data = json.decode(response.body);

      if (data["success"] == true) {
        fetchplaces();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ลบสินค้าเรียบร้อย")),
        );
      }
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ CONFIRM DELETE
  ////////////////////////////////////////////////////////////

  void confirmDelete(dynamic places) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("ยืนยันการลบ"),
        content: Text("ต้องการลบ ${places['name']} ?"),
        actions: [
          TextButton(
            child: const Text("ยกเลิก"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("ลบ"),
            onPressed: () {
              Navigator.pop(context);
              deleteplaces(int.parse(places['id'].toString()));
            },
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  // ✅ OPEN EDIT PAGE
  ////////////////////////////////////////////////////////////

  void openEdit(dynamic places) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTouristPage(tourist: places),
      ),
    ).then((value) => fetchplaces());
  }



  ////////////////////////////////////////////////////////////
  // ✅ UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สถานที่ท่องเที่ยว')),

      body: Column(
        children: [

          //////////////////////////////////////////////////////
          // 🔍 SEARCH BOX
          //////////////////////////////////////////////////////

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search place',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterplaces,
            ),
          ),

          //////////////////////////////////////////////////////
          // 📦 places LIST
          //////////////////////////////////////////////////////

          Expanded(
            child: filteredplaces.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80), // ✅ สำคัญมาก
                    itemCount: filteredplaces.length,
                    itemBuilder: (context, index) {
                      final places = filteredplaces[index];

                      //////////////////////////////////////////////////////
                      // ✅ IMAGE URL (สำคัญมาก)
                      //////////////////////////////////////////////////////

                     String imageUrl =
                         "${baseUrl}images/${places['image']}";
    
                      return Card(
                        child: ListTile(

                          //////////////////////////////////////////////////
                          // 🖼 IMAGE FROM SERVER
                          //////////////////////////////////////////////////

                          leading: SizedBox(
                            width: 80,
                            height: 80,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          ),

                          //////////////////////////////////////////////////
                          // 🏷 NAME
                          //////////////////////////////////////////////////

                          title: Text(places['name'] ?? 'No Name'),


                          subtitle: Text(places['province'] ?? ''),


                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                openEdit(places);
                              } else if (value == 'delete') {
                                confirmDelete(places);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('แก้ไข'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('ลบ'),
                              ),
                            ],
                          ),


                          
                          //////////////////////////////////////////////////
                          // 👉 DETAIL PAGE
                          //////////////////////////////////////////////////

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    placesDetail(places: places),
                                    
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      ////////////////////////////////////////////////////////
      // ✅ ADD BUTTON
      ////////////////////////////////////////////////////////

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTouristPage(),
            ),
          ).then((value) {
            fetchplaces(); // ✅ รีโหลดหลังเพิ่มสินค้า
          });
        },
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// ✅ places DETAIL PAGE
//////////////////////////////////////////////////////////////

class placesDetail extends StatelessWidget {
  final dynamic places;

  const placesDetail({super.key, required this.places});

  @override
  Widget build(BuildContext context) {

    ////////////////////////////////////////////////////////////
    // ✅ IMAGE URL
    ////////////////////////////////////////////////////////////

    String imageUrl =
        "${baseUrl}images/${places['image']}";

    return Scaffold(
      appBar: AppBar(
        title: Text(places['name'] ?? 'Detail'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //////////////////////////////////////////////////////
            // 🖼 IMAGE
            //////////////////////////////////////////////////////

            Center(
              child: Image.network(
                imageUrl,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 100),
              ),
            ),

            const SizedBox(height: 20),

            //////////////////////////////////////////////////////
            // 🏷 NAME
            //////////////////////////////////////////////////////

            Text(
              places['name'] ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            //////////////////////////////////////////////////////
            // 📝 description
            //////////////////////////////////////////////////////


            Text(places['description'] ?? ''),

            const SizedBox(height: 10),

            //////////////////////////////////////////////////////
            // 📝 address
            //////////////////////////////////////////////////////

            Text(
              'ที่อยู่: ${places['address']}',
              style: const TextStyle(fontSize: 18),
            ),

            //////////////////////////////////////////////////////
            // 💰 province
            //////////////////////////////////////////////////////

            Text(
              'จังหวัด: ${places['province']}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
