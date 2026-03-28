import 'package:flutter/material.dart';
import 'core/giao_dien_chung.dart';
import 'core/dinh_tuyen.dart';
import 'iphone_frame.dart'; 

class QuanLyChiTieuApp extends StatelessWidget {
  const QuanLyChiTieuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: GiaoDienChung.theme,
      initialRoute: DinhTuyen.khoiDong,
      routes: DinhTuyen.routes,

      // 🔥 Bọc toàn bộ app bằng khung iPhone
      builder: (context, child) {
        return IPhone12Frame(
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
