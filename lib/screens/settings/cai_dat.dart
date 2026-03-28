import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Để hiển thị thông tin người dùng
import '../auth/dang_nhap.dart'; 

class CaiDatScreen extends StatelessWidget {
  const CaiDatScreen({super.key});

  // ✅ GIỮ NGUYÊN LOGIC CŨ CỦA BẠN (Đã test là chạy được)
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn thoát ứng dụng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              // Dùng đúng lệnh cũ của bạn để đảm bảo đăng nhập lại được
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const DangNhapScreen()),
                (route) => false,
              );
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin user để hiển thị cho đẹp
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF), // Nền trắng xanh hiện đại
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 50, left: 14, right: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER: THÔNG TIN TÀI KHOẢN (Gradient Card) ---
              _buildProfileCard(user),

              const SizedBox(height: 20),

              // --- NHÓM 1: TÀI KHOẢN ---
              _buildSectionTitle("Tài khoản"),
              _buildSettingGroup([
                _buildSettingItem(Icons.person_outline_rounded, "Thông tin cá nhân", Colors.blueAccent),
                _buildDivider(),
                _buildSettingItem(Icons.notifications_none_rounded, "Thông báo chi tiêu", Colors.orangeAccent),
                _buildDivider(),
                _buildSettingItem(Icons.security_rounded, "Bảo mật & Riêng tư", Colors.greenAccent.shade700),
              ]),

              const SizedBox(height: 20),

              // --- NHÓM 2: HỖ TRỢ ---
              _buildSectionTitle("Hỗ trợ"),
              _buildSettingGroup([
                _buildSettingItem(Icons.help_outline_rounded, "Trung tâm trợ giúp", Colors.purpleAccent),
                _buildDivider(),
                _buildSettingItem(Icons.info_outline_rounded, "Về ứng dụng", Colors.tealAccent.shade700),
              ]),

              const SizedBox(height: 25),

              // --- NÚT ĐĂNG XUẤT (Theo phong cách đẹp nhưng dùng logic cũ) ---
              _buildLogoutButton(context),

              const SizedBox(height: 120), // Khoảng trống tránh bị Bottom Bar che
            ],
          ),
        ),
      ),
    );
  }

  // Widget tiêu đề mục
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
      ),
    );
  }

  // Thẻ Profile hiển thị thông tin
  Widget _buildProfileCard(User? user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E3192).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white24,
            backgroundImage: NetworkImage(user?.photoURL ?? "https://via.placeholder.com/150"),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? "Người dùng",
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  user?.email ?? "Chưa kết nối email",
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Khung bọc nhóm cài đặt
  Widget _buildSettingGroup(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: items),
    );
  }

  // Từng dòng mục cài đặt
  Widget _buildSettingItem(IconData icon, String title, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade50, indent: 70);
  }

  // Widget Nút Đăng Xuất (Dùng logic _handleLogout cũ)
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () => _handleLogout(context),
        icon: const Icon(Icons.logout_rounded, color: Colors.white),
        label: const Text(
          "ĐĂNG XUẤT TÀI KHOẢN",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE53935),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 5,
          shadowColor: const Color(0xFFE53935).withOpacity(0.4),
        ),
      ),
    );
  }
}