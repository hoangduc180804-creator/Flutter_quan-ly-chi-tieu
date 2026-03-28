import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/dinh_tuyen.dart';

class ManHinhKhoiDong extends StatefulWidget {
  const ManHinhKhoiDong({super.key});

  @override
  State<ManHinhKhoiDong> createState() => _ManHinhKhoiDongState();
}

class _ManHinhKhoiDongState extends State<ManHinhKhoiDong> {
  @override
  void initState() {
    super.initState();
    // Chuyển màn hình sau 4 giây (như code cũ của bạn)
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, DinhTuyen.dangNhap);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          // Tạo nền Gradient xanh ngọc/xanh lá tạo cảm giác tài chính an toàn
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 99, 82, 49), 
              Color.fromARGB(255, 104, 95, 53), 
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Phần Logo và Tên App
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(25), // Tăng padding lên chút cho đẹp
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    // --- THAY ĐỔI Ở ĐÂY: Dùng Image.asset thay vì Icon ---
                    child: ClipOval( // Bo tròn ảnh nếu ảnh của bạn hình vuông
                      child: Image.asset(
                        'assets/icon.png', 
                        width: 100, // Độ rộng ảnh
                        height: 100, // Độ cao ảnh
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Quản Lý Chi Tiêu',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5, // Giãn chữ cho thoáng
                    ),
                  ),
                ],
              ),
            ),
            
            // Phần Loading ở dưới cùng
            const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
          ],
        ),
      ),
    );
  }
}