import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:exam_9_136/controllers/auth_controller.dart';
import 'package:exam_9_136/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _loading = false;

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _login() async {
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();
    setState(() => _loading = true);
    try {
      await AuthController.login(_email, _password);
      // สำเร็จ: AuthGate ใน main.dart จะพาไปหน้า Home เอง
    } catch (e) {
      if (mounted) _showMessage(AuthController.errorMessage(e));
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _seed() async {
    setState(() => _loading = true);
    try {
      await AuthController.seedTestAccounts();
      if (mounted) {
        _showMessage("สร้างบัญชีทดสอบแล้ว: admin@test.com / operator@test.com (รหัสผ่าน 123456)");
      }
    } catch (e) {
      if (mounted) _showMessage(AuthController.errorMessage(e));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AeroMRO - เข้าสู่ระบบ"),
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
                const SizedBox(height: 20),
                const Center(
                  child: Icon(Icons.flight, size: 90, color: Color(0xFF0D47A1)),
                ),
                const Center(
                  child: Text("Aviation MRO Parts Tracker",
                      style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 25),
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
                  obscureText: true,
                  validator: MultiValidator([
                    RequiredValidator(errorText: "กรุณาป้อนรหัสผ่านด้วยครับ"),
                    MinLengthValidator(6,
                        errorText: "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร"),
                  ]),
                  onSaved: (v) {
                    _password = v!;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("เข้าสู่ระบบ",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _loading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const RegisterScreen()),
                            );
                          },
                    child: const Text("สมัครสมาชิก"),
                  ),
                ),
                const SizedBox(height: 25),
                const Divider(),
                const Text(
                  "สำหรับทดสอบ: admin@test.com (Admin) และ operator@test.com (Operator) รหัสผ่าน 123456",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                TextButton.icon(
                  onPressed: _loading ? null : _seed,
                  icon: const Icon(Icons.manage_accounts),
                  label: const Text("สร้างบัญชีทดสอบ Admin / Operator"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}