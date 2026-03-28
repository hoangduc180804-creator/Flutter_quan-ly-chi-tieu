import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/chi_tieu_provider.dart';

class ThuThachTietKiemScreen extends StatelessWidget {
  const ThuThachTietKiemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'vi_VN');

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9),
      body: Consumer<ChiTieuProvider>(
        builder: (context, provider, child) {
          
          // 1. Lấy dữ liệu theo tháng ĐANG CHỌN
          final danhSach = provider.danhSachTheoThang; 
          final tongChiThangNay = provider.tongChiThangNay;

          // 2. Tính toán tiền theo nhóm
          double tienAnUong = _tinhTienTheoTuKhoa(danhSach, ['ăn', 'uống', 'cơm', 'phở', 'bún', 'cafe', 'trà', 'nước', 'nhậu']);
          double tienMuaSam = _tinhTienTheoTuKhoa(danhSach, ['mua', 'sắm', 'shop', 'quần', 'áo', 'giày', 'tiki', 'shopee', 'lazada','đi','du lịch']);

          return SingleChildScrollView(
            // Không dùng SafeArea ở đây để chủ động kiểm soát khoảng cách top
            child: Column(
              children: [
                // --- 1. KHOẢNG CÁCH TOP 50PX ---
                const SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // --- A. BỘ CHỌN THÁNG ---
                      _buildHeaderSelector(provider),
                      
                      const SizedBox(height: 25),

                      // --- B. CÁC THẺ THỬ THÁCH ---
                      
                      // Card 1: Tổng chi tiêu
                      _buildChallengeCard(
                        title: "Giữ ví an toàn",
                        desc: "Tổng chi tiêu cả tháng",
                        current: tongChiThangNay,
                        goal: 5000000, 
                        icon: Icons.account_balance_wallet,
                        color: Colors.blue,
                        format: formatCurrency,
                      ),

                      const SizedBox(height: 20),

                      // Card 2: Ăn uống
                      _buildChallengeCard(
                        title: "Ăn uống tiết kiệm",
                        desc: "Hạn chế ăn hàng quán",
                        current: tienAnUong,
                        goal: 2000000, 
                        icon: Icons.restaurant_menu,
                        color: Colors.orange,
                        format: formatCurrency,
                      ),

                      const SizedBox(height: 20),

                      // Card 3: Mua sắm
                      _buildChallengeCard(
                        title: "Cai nghiện Shopee",
                        desc: "Mua sắm & Giải trí",
                        current: tienMuaSam,
                        goal: 1500000, 
                        icon: Icons.shopping_bag,
                        color: Colors.purple,
                        format: formatCurrency,
                      ),

                      const SizedBox(height: 30),
                      
                      // Card Động lực
                      _buildMotivationCard(),
                      
                      const SizedBox(height: 150), // Khoảng trống dưới cùng
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Widget Header chọn tháng ---
  Widget _buildHeaderSelector(ChiTieuProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Nút lùi tháng
        InkWell(
          onTap: () => provider.chuyenThang(-1),
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.grey),
          ),
        ),

        // Hiển thị tháng
        Column(
          children: [
            const Text(
              "KẾ HOẠCH TÀI CHÍNH",
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold, 
                color: Colors.grey, 
                letterSpacing: 1.0
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Color(0xFF2D69F3), size: 20),
                const SizedBox(width: 6),
                Text(
                  "Tháng ${provider.thangHienTai}/${provider.namHienTai}",
                  style: const TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.w800, 
                    color: Color(0xFF1E272E)
                  ),
                ),
              ],
            ),
          ],
        ),

        // Nút tiến tháng
        InkWell(
          onTap: () => provider.chuyenThang(1),
          borderRadius: BorderRadius.circular(50),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  // Hàm tính tổng tiền theo từ khóa
  double _tinhTienTheoTuKhoa(List<dynamic> danhSach, List<String> tuKhoas) {
    if (danhSach.isEmpty) return 0;
    return danhSach.where((item) {
      String tenMon = item.ten.toString().toLowerCase();
      return tuKhoas.any((tuKhoa) => tenMon.contains(tuKhoa));
    }).fold(0.0, (sum, item) => sum + item.soTien);
  }

  // Widget hiển thị từng thẻ thử thách
  Widget _buildChallengeCard({
    required String title,
    required String desc,
    required double current,
    required double goal,
    required IconData icon,
    required Color color,
    required NumberFormat format,
  }) {
    double rawProgress = goal == 0 ? 0 : (current / goal);
    double progress = rawProgress.clamp(0.0, 1.0);
    bool isExceeded = current > goal;
    double diff = goal - current;
    
    String statusText = diff >= 0 
        ? "Còn được tiêu: ${format.format(diff)}" 
        : "Đã lố: ${format.format(diff.abs())}";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: isExceeded ? Border.all(color: Colors.red.withOpacity(0.5), width: 1.5) : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isExceeded ? Colors.red.withOpacity(0.1) : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: isExceeded ? Colors.red : color, size: 26),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(desc, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                  ],
                ),
              ),
              if (isExceeded)
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(format.format(current), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isExceeded ? Colors.red : Colors.black87)),
              Text("/ ${format.format(goal)}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          
          // Thanh progress an toàn với LayoutBuilder
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(5)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    width: constraints.maxWidth * progress,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isExceeded ? Colors.red : color,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(statusText, style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: isExceeded ? Colors.red : Colors.green, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

 Widget _buildMotivationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF43cea2), Color(0xFF185a9d)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFF185a9d).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Căn icon lên trên cùng nếu text dài
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trái
              children: [
                // --- TEXT 1: TIÊU ĐỀ MỚI THÊM ---
                const Text(
                  "Góc động lực",
                  style: TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 16
                  ),
                ),
                
                const SizedBox(height: 5), // Khoảng cách giữa 2 dòng
                
                // --- TEXT 2: CÂU NÓI CŨ ---
                Text(
                  "Kỷ luật là cầu nối giữa mục tiêu và thành tựu. Cố lên!",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9), // Màu nhạt hơn xíu
                    fontWeight: FontWeight.w500, 
                    fontSize: 13,
                    height: 1.4 // Tăng độ cao dòng cho dễ đọc
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}