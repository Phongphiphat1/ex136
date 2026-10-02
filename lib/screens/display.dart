import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_9_136/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:exam_9_136/controllers/part_controller.dart';

import 'package:exam_9_136/screens/formscreen.dart';
import 'package:exam_9_136/widgets/app_bar_actions.dart';

class DisplayScreen extends StatefulWidget {
  final AppUser user;
  const DisplayScreen({super.key, required this.user});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  // ปลดระวางชิ้นส่วน (Scrap) = ลบเอกสารออกจาก Firestore (เฉพาะ Admin)
  Future<void> scrapPart(String documentId) async {
    try {
      await PartController.delete(widget.user, documentId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> showScrapConfirmation(String documentId, String serial) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการปลดระวางชิ้นส่วน (Scrap)'),
          content: Text('คุณต้องการปลดระวาง $serial จริงๆ ใช่ไหมครับ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                await scrapPart(documentId);
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('ปลดระวาง'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = widget.user.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text("สถานะอะไหล่อากาศยาน"),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        actions: [AppBarActions(user: widget.user)],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: PartController.stream(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("เกิดข้อผิดพลาด: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("ยังไม่มีข้อมูลอะไหล่"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final document = snapshot.data!.docs[index];
              final cycles = document["remainingCycles"] as String;
              // เหลือน้อยกว่า 500 รอบ ให้เตือนด้วยสีแดง
              final bool low = (int.tryParse(cycles) ?? 0) < 500;

              return Container(
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor:
                        low ? Colors.red.shade300 : Colors.lightBlue.shade200,
                    child: FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(cycles),
                      ),
                    ),
                  ),
                  title: Text(document["serial"]),
                  subtitle: Text(
                      "${document["module"]}\nชั่วโมงบิน: ${document["flightHours"]} ชม. | Cycles เหลือ: $cycles"),
                  isThreeLine: true,
                  // RBAC: Operator จะไม่เห็นปุ่ม Edit / Delete
                  trailing: isAdmin
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FormScreen(
                                      user: widget.user,
                                      documentId: document.id,
                                      serial: document["serial"],
                                      module: document["module"],
                                      email: document["email"],
                                      flightHours: document["flightHours"],
                                      remainingCycles:
                                          document["remainingCycles"],
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await showScrapConfirmation(
                                    document.id, document["serial"]);
                              },
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}