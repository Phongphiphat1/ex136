import 'package:exam_9_136/models/app_user.dart';
import 'package:exam_9_136/models/part.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:exam_9_136/controllers/part_controller.dart';
import 'package:exam_9_136/widgets/app_bar_actions.dart';

class FormScreen extends StatefulWidget {
  final AppUser user;

  // ถ้า documentId != null แปลว่าเป็นโหมดแก้ไข (Inspection Update) ใช้ได้เฉพาะ Admin
  final String? documentId;
  final String? serial;
  final String? module;
  final String? email;
  final String? flightHours;
  final String? remainingCycles;

  const FormScreen({
    super.key,
    required this.user,
    this.documentId,
    this.serial,
    this.module,
    this.email,
    this.flightHours,
    this.remainingCycles,
  });

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final formKey = GlobalKey<FormState>();
  Part myPart = Part(
      serial: '', module: '', email: '', flightHours: '', remainingCycles: '');

  bool get isEdit => widget.documentId != null;

  Future<void> _savePart() async {
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();

    try {
      if (isEdit) {
        await PartController.update(widget.user, widget.documentId!, myPart);
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        await PartController.create(myPart);
        formKey.currentState!.reset();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("บันทึกข้อมูลอะไหล่เรียบร้อยแล้ว")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            isEdit ? "แก้ไขผลตรวจสภาพ (Inspection)" : "ตรวจเช็กและบันทึกอะไหล่"),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        actions: [AppBarActions(user: widget.user)],
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
                const Text("หมายเลขประจำชิ้นส่วน (Part Serial No.)",
                    style: TextStyle(fontSize: 18)),
                TextFormField(
                  initialValue: widget.serial,
                  decoration:
                      const InputDecoration(hintText: "เช่น PN-CFM56-992"),
                  validator: RequiredValidator(
                      errorText: "กรุณาป้อนหมายเลขประจำชิ้นส่วนด้วยครับ"),
                  onSaved: (serial) {
                    myPart.serial = serial!;
                  },
                ),
                const SizedBox(height: 15),
                const Text("ชื่อโมดูลเครื่องบิน",
                    style: TextStyle(fontSize: 18)),
                TextFormField(
                  initialValue: widget.module,
                  decoration: const InputDecoration(
                      hintText: "เช่น Turbine Blade, Landing Gear, Avionics"),
                  validator: RequiredValidator(
                      errorText: "กรุณาป้อนชื่อโมดูลด้วยครับ"),
                  onSaved: (module) {
                    myPart.module = module!;
                  },
                ),
                const SizedBox(height: 15),
                const Text("อีเมลวิศวกรผู้ถือไลเซนส์ (Certifying Engineer)",
                    style: TextStyle(fontSize: 18)),
                TextFormField(
                  initialValue: widget.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: MultiValidator([
                    EmailValidator(errorText: "รูปแบบอีเมลไม่ถูกต้อง"),
                    RequiredValidator(errorText: "กรุณาป้อนอีเมลด้วยครับ"),
                  ]),
                  onSaved: (email) {
                    myPart.email = email!;
                  },
                ),
                const SizedBox(height: 15),
                const Text("จำนวนชั่วโมงบินที่ใช้ไป (Flight Hours)",
                    style: TextStyle(fontSize: 18)),
                TextFormField(
                  initialValue: widget.flightHours,
                  keyboardType: TextInputType.number,
                  validator: MultiValidator([
                    RequiredValidator(errorText: "กรุณาป้อนชั่วโมงบินด้วยครับ"),
                    PatternValidator(r'^\d+$',
                        errorText: "กรุณาป้อนเป็นตัวเลขเท่านั้น"),
                  ]),
                  onSaved: (hours) {
                    myPart.flightHours = hours!;
                  },
                ),
                const SizedBox(height: 15),
                const Text("รอบการบินคงเหลือก่อน Overhaul (Flight Cycles)",
                    style: TextStyle(fontSize: 18)),
                TextFormField(
                  initialValue: widget.remainingCycles,
                  keyboardType: TextInputType.number,
                  validator: MultiValidator([
                    RequiredValidator(
                        errorText: "กรุณาป้อนรอบการบินคงเหลือด้วยครับ"),
                    PatternValidator(r'^\d+$',
                        errorText: "กรุณาป้อนเป็นตัวเลขเท่านั้น"),
                  ]),
                  onSaved: (cycles) {
                    myPart.remainingCycles = cycles!;
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
                    onPressed: _savePart,
                    child: Text(
                      isEdit ? "บันทึกการแก้ไข" : "บันทึก",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
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