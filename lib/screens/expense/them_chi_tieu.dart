import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/chi_tieu_provider.dart';

class ThemChiTieuScreen extends StatefulWidget {
  const ThemChiTieuScreen({super.key});

  @override
  State<ThemChiTieuScreen> createState() => _ThemChiTieuScreenState();
}

class _ThemChiTieuScreenState extends State<ThemChiTieuScreen> {
  final TextEditingController _tenCtrl = TextEditingController();
  final TextEditingController _tienCtrl = TextEditingController();
  
  // Mặc định ngày hiện tại
  DateTime _ngayDuocChon = DateTime.now();
  
  // Biến trạng thái loading
  bool _dangXuLy = false; 

  @override
  void dispose() {
    _tenCtrl.dispose();
    _tienCtrl.dispose();
    super.dispose();
  }

  void _chonNgay() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _ngayDuocChon,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF2D69F3),
              onPrimary: Colors.white,
              surface: Color(0xFF1E272E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _ngayDuocChon) {
      setState(() {
        _ngayDuocChon = picked;
      });
    }
  }

  // --- HÀM LƯU ĐÃ SỬA (KHÔNG THOÁT MÀN HÌNH) ---
  void _luuChiTieu(BuildContext context) async {
    if (_dangXuLy) return; // Chặn bấm liên tục

    final ten = _tenCtrl.text.trim();
    final tien = double.tryParse(_tienCtrl.text.replaceAll(',', '')) ?? 0;

    if (ten.isEmpty || tien <= 0) {
      _showToast(context, 'Vui lòng nhập tên và số tiền hợp lệ', isError: true);
      return;
    }

    // 1. Bắt đầu xoay loading
    setState(() {
      _dangXuLy = true;
    });

    try {
      // 2. Gọi Provider để lưu vào Firebase
      await Provider.of<ChiTieuProvider>(context, listen: false).themChiTieu(
        ten: ten,
        soTien: tien,
        ngayChon: _ngayDuocChon,
      );

      if (!mounted) return;

      // 3. THÀNH CÔNG:
      // - Không gọi Navigator.pop nữa (để giữ nguyên màn hình)
      // - Xóa ô nhập liệu để nhập cái mới
      _tenCtrl.clear();
      _tienCtrl.clear();
      
      // - Ẩn bàn phím
      FocusScope.of(context).unfocus();

      // - Tắt loading
      setState(() {
        _dangXuLy = false;
        // Nếu muốn reset ngày về hôm nay thì mở comment dòng dưới:
        // _ngayDuocChon = DateTime.now(); 
      });

      // 4. Hiện thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text('Đã lưu "$ten" thành công!')),
            ],
          ),
          backgroundColor: Colors.green, // Màu xanh lá báo thành công
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

    } catch (e) {
      // Nếu lỗi
      if (mounted) {
        setState(() {
          _dangXuLy = false;
        });
        _showToast(context, 'Lỗi: $e', isError: true);
      }
    }
  }

  void _showToast(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF2D69F3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F171A),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const Text(
                'Thêm Chi Tiêu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Nhập chi tiết giao dịch để quản lý tài chính',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
              ),

              const SizedBox(height: 10),

              // KHỐI NHẬP LIỆU
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        _buildInput(
                          controller: _tenCtrl,
                          label: 'Nội dung chi tiêu',
                          hint: 'Ví dụ: Ăn trưa, Cafe...',
                          icon: Icons.edit_note_rounded,
                          activeColor: const Color(0xFF2D69F3),
                        ),
                        const SizedBox(height: 30),
                        _buildInput(
                          controller: _tienCtrl,
                          label: 'Số tiền chi (VNĐ)',
                          hint: '0',
                          icon: Icons.payments_outlined,
                          activeColor: Colors.orangeAccent,
                          keyboardType: TextInputType.number,
                          isMoney: true,
                        ),
                        
                        const SizedBox(height: 30),

                        // CHỌN NGÀY
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'THỜI GIAN',
                              style: TextStyle(
                                color: Colors.greenAccent.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 10),
                            InkWell(
                              onTap: _chonNgay,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1)))
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_month, color: Colors.greenAccent, size: 24),
                                    const SizedBox(width: 15),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(_ngayDuocChon),
                                      style: const TextStyle(color: Colors.white, fontSize: 18),
                                    ),
                                    const Spacer(),
                                    const Icon(Icons.arrow_drop_down, color: Colors.white54),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // NÚT LƯU
              GestureDetector(
                onTap: () => _luuChiTieu(context),
                child: Container(
                  width: double.infinity,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _dangXuLy 
                          ? [Colors.grey.shade800, Colors.grey.shade900]
                          : [const Color(0xFF2D69F3), const Color(0xFF1A46A1)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: _dangXuLy ? Colors.transparent : const Color(0xFF2D69F3).withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Center(
                    child: _dangXuLy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'XÁC NHẬN LƯU',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color activeColor,
    TextInputType keyboardType = TextInputType.text,
    bool isMoney = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: activeColor.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            color: isMoney ? Colors.orangeAccent : Colors.white,
            fontSize: 20,
            fontWeight: isMoney ? FontWeight.bold : FontWeight.normal,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 18),
            prefixIcon: Icon(icon, color: activeColor, size: 24),
            suffixText: isMoney ? 'đ' : null,
            suffixStyle: const TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: activeColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}