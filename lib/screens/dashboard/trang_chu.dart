import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/chi_tieu_provider.dart';
import '../expense/sua_chi_tieu.dart';
import '../expense/them_chi_tieu.dart';

class TrangChuScreen extends StatelessWidget {
  const TrangChuScreen({super.key});

  // --- HÀM XỬ LÝ XÓA TOÀN BỘ ---
  // Thêm tham số 'ngayCanXoa' để biết đang xóa tháng nào
  void _confirmDeleteMonth(BuildContext context, DateTime ngayCanXoa) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A2429),
        title: Text(
          "Xóa dữ liệu tháng ${ngayCanXoa.month}?",
          style: const TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Hành động này sẽ xóa các khoản chi tiêu trong tháng này. Dữ liệu các tháng khác vẫn an toàn.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx); // Đóng hộp thoại trước

              // --- SỬA LẠI DÒNG NÀY ---
              // Gọi hàm và truyền tháng, năm vào
              await context.read<ChiTieuProvider>().xoaChiTieuTheoThang(
                ngayCanXoa.month,
                ngayCanXoa.year,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã xóa dữ liệu tháng này!")),
                );
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tự động lấy dữ liệu khi màn hình được xây dựng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChiTieuProvider>().layDuLieu();
    });

    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F171A),
      // --- NÚT THÊM CHI TIÊU ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2D69F3),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ThemChiTieuScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Consumer<ChiTieuProvider>(
                // Dùng Consumer ở đây để bao bọc cả Header và List
                // giúp UI cập nhật mượt mà khi đổi tháng
                builder: (context, provider, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(user),
                      const SizedBox(height: 15),

                      // --- BỘ CHỌN THÁNG MỚI ---
                      _buildMonthSelector(context, provider),
                      const SizedBox(height: 15),

                      // --- THẺ TỔNG TIỀN & NHẬN XÉT ---
                      _buildHeroCard(provider),

                      const SizedBox(height: 20),

                      // Tiêu đề danh sách
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Chi tiêu tháng ${provider.thangHienTai}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // 1. Tạo đối tượng DateTime từ dữ liệu trong Provider
                              // Mình giả định provider của bạn có biến 'namHienTai'.
                              // Nếu tên khác (ví dụ: currentYear), bạn hãy sửa lại nhé.
                              DateTime ngayCanXoa = DateTime(
                                provider.namHienTai,
                                provider.thangHienTai,
                              );

                              // 2. Gọi hàm xác nhận xóa tháng (đã viết ở bước trước)
                              _confirmDeleteMonth(context, ngayCanXoa);
                            },
                            icon: const Icon(
                              Icons.delete_sweep_outlined,
                              color: Colors.redAccent,
                              size: 28,
                            ),
                            // 3. Sửa tooltip cho đúng ý nghĩa
                            tooltip: "Xóa dữ liệu tháng này",
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // --- DANH SÁCH CHI TIÊU (Đã lọc) ---
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final danhSach = provider
                                .danhSachTheoThang; // Lấy list theo tháng

                            if (danhSach.isEmpty) return _buildEmptyState();

                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 100),
                              itemCount: danhSach.length,
                              itemBuilder: (context, index) {
                                final item = danhSach[index];
                                return _buildTransactionCard(context, item);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CÁC WIDGET PHỤ TRỢ ---

  Widget _buildHeader(User? user) {
    String displayName = user?.displayName ?? "Người dùng";
    String photoUrl =
        user?.photoURL ??
        'https://ui-avatars.com/api/?name=$displayName&background=random';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Xin chào,",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            Text(
              displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        CircleAvatar(radius: 22, backgroundImage: NetworkImage(photoUrl)),
      ],
    );
  }

  // Widget chọn tháng (MỚI)
  Widget _buildMonthSelector(BuildContext context, ChiTieuProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white70,
              size: 13,
            ),
            onPressed: () => provider.chuyenThang(-1),
          ),
          Text(
            "Tháng ${provider.thangHienTai}, ${provider.namHienTai}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 13,
            ),
            onPressed: () => provider.chuyenThang(1),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị tổng tiền và nhận xét (CẬP NHẬT)
  Widget _buildHeroCard(ChiTieuProvider provider) {
    final currencyFormat = NumberFormat('#,###', 'vi_VN');

    // Lấy thông tin nhận xét từ provider
    final nhanXet = provider.layNhanXetThongMinh;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D69F3), Color(0xFF1A2429)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D69F3).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TỔNG CHI TIÊU THÁNG',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${currencyFormat.format(provider.tongChiThangNay)} đ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),

          // Phần hiển thị so sánh/nhận xét
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.insights, color: nhanXet['color'], size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    nhanXet['txt'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, dynamic item) {
    final currencyFormat = NumberFormat('#,###', 'vi_VN');

    // Quan trọng: Dùng ID để xóa thay vì index
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        // Gọi hàm xóa theo ID
        if (item.id != null) {
          context.read<ChiTieuProvider>().xoaChiTieu(item.id!);
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent),
      ),
      child: GestureDetector(
        onTap: () {
          // Khi chuyển sang màn hình sửa, cần truyền ID để cập nhật đúng document
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SuaChiTieuScreen(
                // Lưu ý: Bạn cần đảm bảo SuaChiTieuScreen nhận tham số 'id'
                // Nếu chưa có, hãy thêm final String? id vào SuaChiTieuScreen
                index:
                    0, // Không dùng index nữa nhưng giữ để tránh lỗi compile nếu chưa sửa file kia
                id: item.id,
                ten: item.ten,
                soTien: item.soTien,
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.orangeAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.ten,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy - HH:mm').format(item.thoiGian),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '-${currencyFormat.format(item.soTien)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 60,
            color: Colors.white.withOpacity(0.05),
          ),
          const SizedBox(height: 16),
          Text(
            "Tháng này chưa có dữ liệu",
            style: TextStyle(color: Colors.white.withOpacity(0.2)),
          ),
        ],
      ),
    );
  }
}
