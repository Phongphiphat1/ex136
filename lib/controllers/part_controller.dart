import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_9_136/models/app_user.dart';
import 'package:exam_9_136/models/part.dart';

class PartController {
  static final CollectionReference<Map<String, dynamic>> _parts =
      FirebaseFirestore.instance.collection('parts');

  // Read: Real-time
  static Stream<QuerySnapshot<Map<String, dynamic>>> stream() {
    return _parts.snapshots();
  }

  // Create: ทั้ง Admin และ Operator ทำได้
  static Future<void> create(Part part) async {
    await _parts.add(part.toMap());
  }

  // Update: เฉพาะ Admin
  static Future<void> update(AppUser user, String id, Part part) async {
    if (!user.isAdmin) {
      throw Exception('สิทธิ์ไม่เพียงพอ: เฉพาะ Admin เท่านั้นที่แก้ไขได้');
    }
    await _parts.doc(id).update(part.toMap());
  }

  // Delete: เฉพาะ Admin
  static Future<void> delete(AppUser user, String id) async {
    if (!user.isAdmin) {
      throw Exception('สิทธิ์ไม่เพียงพอ: เฉพาะ Admin เท่านั้นที่ลบได้');
    }
    await _parts.doc(id).delete();
  }
}