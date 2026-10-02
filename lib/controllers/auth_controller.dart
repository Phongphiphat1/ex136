import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_9_136/models/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthController {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final CollectionReference<Map<String, dynamic>> _users =
      FirebaseFirestore.instance.collection('users');

  // true ระหว่างสร้างบัญชีทดสอบ เพื่อไม่ให้แอพเด้งเข้าหน้า Home ชั่วคราว
  static final ValueNotifier<bool> seeding = ValueNotifier(false);

  static Stream<User?> authChanges() => _auth.authStateChanges();

  // อ่านข้อมูลสมาชิก (uid, name, email, role) จาก collection users แบบ Real-time
  static Stream<AppUser?> profileStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromMap(doc.data()!);
    });
  }

  static Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
  }

  // สมัครสมาชิกใหม่ → role เริ่มต้นเป็น Operator
  static Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    final user = AppUser(
      uid: cred.user!.uid,
      name: name.trim(),
      email: email.trim(),
      role: 'Operator',
    );
    await _users.doc(user.uid).set(user.toMap());
  }

  static Future<void> signOut() => _auth.signOut();

  static Future<void> _ensureAccount({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    UserCredential cred;
    try {
      cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        cred = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        rethrow;
      }
    }
    final user = AppUser(
        uid: cred.user!.uid, name: name, email: email, role: role);
    await _users.doc(user.uid).set(user.toMap());
    await _auth.signOut();
  }

  // สร้างบัญชีทดสอบ 2 บัญชีตามที่ข้อสอบกำหนด
  static Future<void> seedTestAccounts() async {
    seeding.value = true;
    try {
      await _ensureAccount(
        email: 'admin@test.com',
        password: '123456',
        name: 'Admin Test',
        role: 'Admin',
      );
      await _ensureAccount(
        email: 'operator@test.com',
        password: '123456',
        name: 'Operator Test',
        role: 'Operator',
      );
    } finally {
      seeding.value = false;
    }
  }

  static String errorMessage(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
        case 'email-already-in-use':
          return 'อีเมลนี้ถูกใช้สมัครแล้ว';
        case 'weak-password':
          return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
        case 'invalid-email':
          return 'รูปแบบอีเมลไม่ถูกต้อง';
        case 'operation-not-allowed':
          return 'ยังไม่ได้เปิด Email/Password ใน Firebase Authentication';
        case 'network-request-failed':
          return 'เชื่อมต่ออินเทอร์เน็ตไม่ได้';
        default:
          return 'เกิดข้อผิดพลาด: ${e.code}';
      }
    }
    return 'เกิดข้อผิดพลาด: $e';
  }
}