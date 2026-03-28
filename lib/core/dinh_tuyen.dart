import 'package:flutter/material.dart';
import '../screens/splash/man_hinh_khoi_dong.dart';
import '../screens/auth/dang_nhap.dart';
import '../screens/auth/dang_ky.dart';
import '../screens/dashboard/main_dashboard.dart';
import '../screens/dashboard/trang_chu.dart';


class DinhTuyen {
  static const String khoiDong = '/';
  static const String dangNhap = '/dang-nhap';
  static const String dangKy = '/dang-ky';
  static const String trangChu = '/trang-chu';
  static const String dashboard = '/dashboard';


  static Map<String, WidgetBuilder> get routes {
    return {
      khoiDong: (context) => const ManHinhKhoiDong(),
      dangNhap: (context) => const DangNhapScreen(),
      dangKy: (context) => const DangKyScreen(),
      trangChu: (context) => const TrangChuScreen(),
      dashboard: (context) => const MainDashboard(),
    };
  }
}
