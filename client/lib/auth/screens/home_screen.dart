import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../admin/screens/admin_dashboard_screen.dart';
import '../../books/screens/book_list_screen.dart';
import '../services/role_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RoleService _roleService = RoleService();
  bool _loading = true;
  Widget? _screen;

  @override
  void initState() {
    super.initState();
    _redirectBasedOnRole();
  }

  Future<void> _redirectBasedOnRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final role = await _roleService.getRole(user.uid);

    if (!mounted) return;

    setState(() {
      _screen = (role == 'admin')
          ? const AdminDashboardScreen()
          : const BookListScreen();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _screen!;
  }
}