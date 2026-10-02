import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:exam_9_136/controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  String _name = '';
  String _email = '';
  bool _loading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();
    setState(() => _loading = true);
    try {
      await AuthController.register(
        name: _name,
        email: _email,
        password: _passwordController.text,
      );
      if (!mounted) return;
      // ปิดหน้าสมัคร → AuthGate จะแสดงหน้า Home ให้เอง (Role = Operator)
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AuthController.errorMessage(e))));
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("สมัครสมาชิก"),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ชื่อ-นามสกุล", style: TextStyle(fontSize: 18)),
                TextFormField(
                  validator:
                      RequiredValidator(errorText: "กรุณาป้อนชื่อด้วยครับ"),
                  onSaved: (v) {
                    _name = v!;
                  },
                ),
                const SizedBox(height: 15),
                const Text("อีเมล", style: TextStyle(fontSize: 18)),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  validator: MultiValidator([
                    EmailValidator(errorText: "รูปแบบอีเมลไม่ถูกต้อง"),
                    RequiredValidator(errorText: "กรุณาป้อนอีเมลด้วยครับ"),
                  ]),
                  onSaved: (v) {
                    _email = v!;
                  },
                ),
                const SizedBox(height: 15),
                const Text("รหัสผ่าน", style: TextStyle(fontSize: 18)),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: MultiValidator([
                    RequiredValidator(errorText: "กรุณาป้อนรหัสผ่านด้วยครับ"),
                    MinLengthValidator(6,
                        errorText: "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร"),
                  ]),
                ),
                const SizedBox(height: 15),
                const Text("ยืนยันรหัสผ่าน", style: TextStyle(fontSize: 18)),
                TextFormField(
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "กรุณายืนยันรหัสผ่านด้วยครับ";
                    }
                    if (v != _passwordController.text) {
                      return "รหัสผ่านไม่ตรงกัน";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                const Text(
                  "สมาชิกใหม่จะได้สิทธิ์ Operator (ดูและบันทึกข้อมูลได้ แก้ไข/ลบไม่ได้)",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _loading ? null : _register,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("สมัครสมาชิก",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}