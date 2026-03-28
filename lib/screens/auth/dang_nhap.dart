import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dang_nhap_provider.dart';
import '../../core/dinh_tuyen.dart';

class DangNhapScreen extends StatefulWidget {
  const DangNhapScreen({super.key});

  @override
  State<DangNhapScreen> createState() => _DangNhapScreenState();
}

class _DangNhapScreenState extends State<DangNhapScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<DangNhapProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          Container(color: const Color(0xFF0F171A)),
          
          // Hiệu ứng ánh sáng Teal phía sau
          Positioned(
            top: 150,
            left: -100,
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
                          child: const Icon(Icons.fingerprint, size: 50, color: Colors.tealAccent),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'QUẢN LÝ CHI TIÊU',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                        const SizedBox(height: 30),

                        _buildGlassInput(hint: 'Email', icon: Icons.email_outlined, controller: _emailController),
                        const SizedBox(height: 20),
                        _buildGlassInput(hint: 'Mật khẩu', icon: Icons.lock_outline, isPassword: true, controller: _passwordController),
                        const SizedBox(height: 30),

                        // Nút Đăng nhập Email
                        _buildPrimaryButton(
                          text: 'ĐĂNG NHẬP',
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            final message = await authProvider.dangNhap(_emailController.text.trim(), _passwordController.text.trim());
                            if (mounted) setState(() => _isLoading = false);
                            _handleAuthResult(message);
                          },
                        ),

                        const SizedBox(height: 15),

                        // Nút Đăng nhập Google với Logo của bạn
                        _buildGoogleButton(
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            final message = await authProvider.dangNhapGoogle();
                            if (mounted) setState(() => _isLoading = false);
                            _handleAuthResult(message);
                          },
                        ),

                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, DinhTuyen.dangKy),
                          child: Text(
                            "Chưa có tài khoản? Đăng ký ngay",
                            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: Colors.tealAccent)),
            ),
        ],
      ),
    );
  }

  void _handleAuthResult(String? message) {
    if (message == null) {
      Navigator.pushReplacementNamed(context, DinhTuyen.dashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.redAccent));
    }
  }

  Widget _buildPrimaryButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF26A69A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildGoogleButton({required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        // SỬ DỤNG LOGO GOOGLE CỦA BẠN TẠI ĐÂY
        icon: Image.asset('assets/google_logo.png', width: 24, height: 24),
        label: const Text('TIẾP TỤC VỚI GOOGLE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: onPressed,
      ),
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
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}