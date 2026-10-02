import 'package:exam_9_136/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:exam_9_136/controllers/auth_controller.dart';


// แสดงชื่อ + Role ของผู้ใช้ปัจจุบัน และปุ่ม Sign Out บน AppBar
class AppBarActions extends StatelessWidget {
  final AppUser user;
  const AppBarActions({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: "${user.name} (${user.email})",
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: user.isAdmin ? Colors.amber : Colors.lightBlue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user.role,
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ),
        ),
        IconButton(
          tooltip: "Sign Out",
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await AuthController.signOut();
          },
        ),
      ],
    );
  }
}