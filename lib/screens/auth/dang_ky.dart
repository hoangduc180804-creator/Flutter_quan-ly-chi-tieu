import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dang_nhap_provider.dart';
import '../../core/dinh_tuyen.dart';

class DangKyScreen extends StatefulWidget {
  const DangKyScreen({super.key});

  @override
  State<DangKyScreen> createState() => _DangKyScreenState();
}

class _DangKyScreenState extends State<DangKyScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Chống vỡ giao diện khi hiện bàn phím
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          // 1. Nền tối chủ đạo
          Container(color: const Color(0xFF0F171A)),

          // 2. Hiệu ứng ánh sáng Teal phía sau (giống màn hình đăng nhập)
          Positioned(
            bottom: 100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.teal.withOpacity(0.1),
                boxShadow: [
                  BoxShadow(color: Colors.teal.withOpacity(0.1), blurRadius: 100, spreadRadius: 50)
                ],
              ),
            ),
          ),

          // 3. Nội dung chính
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.tealAccent.withOpacity(0.5)),
                          ),
                          child: const Icon(Icons.person_add_alt_1, size: 50, color: Colors.tealAccent),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'TẠO TÀI KHOẢN',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                        const SizedBox(height: 30),

                        _buildGlassInput(hint: 'Email', icon: Icons.email_outlined, controller: _emailController),
                        const SizedBox(height: 20),
                        _buildGlassInput(hint: 'Mật khẩu', icon: Icons.lock_outline, isPassword: true, controller: _passwordController),
                        const SizedBox(height: 20),
                        _buildGlassInput(hint: 'Xác nhận mật khẩu', icon: Icons.lock_reset, isPassword: true, controller: _confirmPasswordController),
                        const SizedBox(height: 30),

                        // Nút Đăng ký
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF26A69A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            onPressed: _isLoading ? null : _handleRegister,
                            child: const Text('ĐĂNG KÝ NGAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),

                        const SizedBox(height: 15),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Đã có tài khoản? Đăng nhập',
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Màn hình loading phủ mờ
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: Colors.tealAccent)),
            ),
        ],
      ),
    );
  }

  // Logic xử lý đăng ký
  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    // 1. Kiểm tra bỏ trống
    if (email.isEmpty || pass.isEmpty || confirmPass.isEmpty) {
      _showSnackBar('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    // 2. Kiểm tra khớp mật khẩu
    if (pass != confirmPass) {
      _showSnackBar('Mật khẩu xác nhận không khớp');
      return;
    }

    // 3. Tiến hành đăng ký
    setState(() => _isLoading = true);
    final authProvider = context.read<DangNhapProvider>();
    final message = await authProvider.dangKy(email, pass);
    
    if (mounted) setState(() => _isLoading = false);

    if (message == null) {
      // Thành công -> Vào Dashboard
      if (mounted) Navigator.pushReplacementNamed(context, DinhTuyen.dashboard);
    } else {
      // Thất bại -> Hiện lỗi từ Firebase
      _showSnackBar(message);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent)
    );
  }

  Widget _buildGlassInput({required String hint, required IconData icon, bool isPassword = false, TextEditingController? controller}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.tealAccent.withOpacity(0.7), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }
}