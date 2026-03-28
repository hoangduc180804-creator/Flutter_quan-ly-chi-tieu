import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chi_tieu_provider.dart';

class SuaChiTieuScreen extends StatefulWidget {
  final int index;
  final String? id; // Giữ nguyên ID để sửa trên Firebase
  final String ten;
  final double soTien;

  const SuaChiTieuScreen({
    super.key,
    required this.index,
    this.id,
    required this.ten,
    required this.soTien,
  });

  @override
  State<SuaChiTieuScreen> createState() => _SuaChiTieuScreenState();
}

class _SuaChiTieuScreenState extends State<SuaChiTieuScreen> {
  late TextEditingController _tenCtrl;
  late TextEditingController _tienCtrl;

  @override
  void initState() {
    super.initState();
    _tenCtrl = TextEditingController(text: widget.ten);
    _tienCtrl = TextEditingController(text: widget.soTien.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _tenCtrl.dispose();
    _tienCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F171A),
      // Bỏ AppBar, dùng SingleChildScrollView để tránh lỗi bàn phím che input
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. KHOẢNG CÁCH TOP 50PX ---
            const SizedBox(height: 50),

            // --- 2. HEADER TỰ LÀM (Back + Title) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Chỉnh sửa chi tiêu",
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- 3. PHẦN NHẬP LIỆU ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Input Tên
                  TextField(
                    controller: _tenCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    decoration: const InputDecoration(
                      labelText: 'Nội dung',
                      labelStyle: TextStyle(color: Color(0xFF2D69F3)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF2D69F3))),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Input Số tiền
                  TextField(
                    controller: _tienCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.orangeAccent, fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      labelText: 'Số tiền (đ)',
                      labelStyle: TextStyle(color: Color(0xFF2D69F3)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orangeAccent)),
                    ),
                  ),
                  
                  // Thay Spacer() bằng khoảng cách cố định vì đang dùng SingleChildScrollView
                  const SizedBox(height: 80),
                  
                  // Nút Lưu
                  ElevatedButton(
                    onPressed: () {
                      // 1. Kiểm tra ID
                      if (widget.id == null) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text("Lỗi: Không tìm thấy ID khoản chi này!"))
                         );
                         return;
                      }

                      // 2. Xử lý dữ liệu
                      double? soTienMoi = double.tryParse(_tienCtrl.text.replaceAll(',', ''));
                      if (soTienMoi == null) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text("Vui lòng nhập số tiền hợp lệ"))
                         );
                         return;
                      }

                      // 3. Gọi Provider update Firebase
                      context.read<ChiTieuProvider>().suaChiTieu(
                        id: widget.id!,
                        tenMoi: _tenCtrl.text,
                        soTienMoi: soTienMoi,
                      );

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D69F3),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                      shadowColor: const Color(0xFF2D69F3).withOpacity(0.5),
                    ),
                    child: const Text('LƯU THAY ĐỔI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  
                  const SizedBox(height: 30), // Khoảng trống dưới cùng
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}