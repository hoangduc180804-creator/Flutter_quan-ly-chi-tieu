// File: screens/dashboard/main_dashboard.dart

import 'package:flutter/material.dart';
import '../../widgets/common/nut_chinh.dart';
import '../dashboard/trang_chu.dart';
import '../analysis/phan_tich_chi_tieu.dart';
import '../expense/them_chi_tieu.dart';
import '../challenge/thu_thach_tiet_kiem.dart';
import '../settings/cai_dat.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TrangChuScreen(),
    PhanTichChiTieuScreen(),
    ThemChiTieuScreen(), 
    ThuThachTietKiemScreen(),
    CaiDatScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F171A),
      extendBody: true,

      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      bottomNavigationBar: NutChinh(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
