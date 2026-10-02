import 'package:exam_9_136/models/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:exam_9_136/controllers/auth_controller.dart';

import 'package:exam_9_136/screens/display.dart';
import 'package:exam_9_136/screens/formscreen.dart';
import 'package:exam_9_136/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AeroMRO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

// ตัดสินใจว่าจะแสดงหน้า Login หรือหน้า Home ตามสถานะการล็อกอิน
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthController.seeding,
      builder: (context, seeding, _) {
        return StreamBuilder<User?>(
          stream: AuthController.authChanges(),
          builder: (context, authSnap) {
            if (authSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            final firebaseUser = authSnap.data;
            if (firebaseUser == null || seeding) {
              return const LoginScreen();
            }
            // ดึง role จาก collection users
            return StreamBuilder<AppUser?>(
              stream: AuthController.profileStream(firebaseUser.uid),
              builder: (context, profileSnap) {
                final appUser = profileSnap.data;
                if (appUser == null) {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          const Text("กำลังโหลดข้อมูลสมาชิก..."),
                          TextButton(
                            onPressed: () => AuthController.signOut(),
                            child: const Text("Sign Out"),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return MyHomePage(user: appUser);
              },
            );
          },
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final AppUser user;
  const MyHomePage({super.key, required this.user});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: TabBarView(
          children: [
            FormScreen(user: widget.user),
            DisplayScreen(user: widget.user),
          ],
        ),
        backgroundColor: const Color(0xFF0D47A1),
        bottomNavigationBar: Container(
          color: const Color(0xFF0D47A1),
          child: const TabBar(
            tabs: [
              Tab(
                text: "บันทึกอะไหล่",
                icon: Icon(Icons.build_circle),
              ),
              Tab(
                text: "สถานะอะไหล่",
                icon: Icon(Icons.flight),
              ),
            ],
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.amber,
          ),
        ),
      ),
    );
  }
}