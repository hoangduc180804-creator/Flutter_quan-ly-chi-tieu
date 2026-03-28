import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/chi_tieu_provider.dart';

class PhanTichChiTieuScreen extends StatefulWidget {
  const PhanTichChiTieuScreen({super.key});

  @override
  State<PhanTichChiTieuScreen> createState() => _PhanTichChiTieuScreenState();
}

class _PhanTichChiTieuScreenState extends State<PhanTichChiTieuScreen> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'vi_VN');

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9), 
      body: Consumer<ChiTieuProvider>(
        builder: (context, provider, child) {
          
          final danhSachHienTai = provider.danhSachTheoThang;
          final tongTien = provider.tongChiThangNay;

          // Gom nhóm dữ liệu
          Map<String, double> groupedData = {};
          for (var item in danhSachHienTai) {
            groupedData[item.ten] = (groupedData[item.ten] ?? 0) + item.soTien;
          }

          // Sắp xếp dữ liệu giảm dần để hiển thị đẹp hơn
          var sortedKeys = groupedData.keys.toList(growable: false)
            ..sort((k1, k2) => groupedData[k2]!.compareTo(groupedData[k1]!));
          Map<String, double> sortedData = {
            for (var k in sortedKeys) k: groupedData[k]!
          };

          return SingleChildScrollView(
            child: Column(
              children: [
                // 1. ✅ CÁCH TOP 50PX NHƯ YÊU CẦU
                const SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // --- HEADER CHỌN THÁNG (Minimalist Style) ---
                      _buildMinimalHeader(provider),

                      const SizedBox(height: 30),

                      if (danhSachHienTai.isEmpty) 
                        _buildEmptyState()
                      else ...[
                        // --- THẺ TỔNG TIỀN (Dark Theme Contrast) ---


                        // --- BIỂU ĐỒ DONUT ---
                        SizedBox(
                          height: 250,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  pieTouchData: PieTouchData(
                                    touchCallback: (event, response) {
                                      setState(() {
                                        if (!event.isInterestedForInteractions || response == null || response.touchedSection == null) {
                                          touchedIndex = -1;
                                          return;
                                        }
                                        touchedIndex = response.touchedSection!.touchedSectionIndex;
                                      });
                                    },
                                  ),
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 100, // Tạo lỗ hổng ở giữa (Donut)
                                  sections: _showingSections(sortedData, tongTien),
                                ),
                              ),
                              // Text ở giữa biểu đồ
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text("Tổng chi", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text(
                                    "${(tongTien / 1000000).toStringAsFixed(1)}M", // Ví dụ: 5.2M
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // --- DANH SÁCH CHI TIẾT (Dạng Thanh Tiến Trình) ---
                        _buildProgressList(sortedData, tongTien, formatCurrency),
                        
                        const SizedBox(height: 50),
                      ],
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

  // Header tối giản, sang trọng hơn
  Widget _buildMinimalHeader(ChiTieuProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => provider.chuyenThang(-1),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back, size: 18),
          ),
        ),
        Column(
          children: [
            Text(
              "THÁNG ${provider.thangHienTai}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1, color: Color(0xFF1E272E)),
            ),
            Text(
              "Năm ${provider.namHienTai}",
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        InkWell(
          onTap: () => provider.chuyenThang(1),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_forward, size: 18),
          ),
        ),
      ],
    );
  }

  // Thẻ Dark Card tạo điểm nhấn "Lạ & Khác biệt"
  

  // Danh sách có thanh Progress Bar bên dưới
  Widget _buildProgressList(Map<String, double> data, double total, NumberFormat format) {
    final List<Color> colors = [
      const Color(0xFF4E54C8), const Color(0xFFFF7E5F), const Color(0xFF00B09B),
      const Color(0xFFFC466B), const Color(0xFFFFD200), const Color(0xFF8E2DE2)
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("PHÂN TÍCH CHI TIẾT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
        const SizedBox(height: 15),
        
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.length,
          separatorBuilder: (c, i) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            String key = data.keys.elementAt(index);
            double value = data.values.elementAt(index);
            double percent = (value / total);
            Color itemColor = colors[index % colors.length];

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(color: itemColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 10),
                        Text(key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      ],
                    ),
                    Text(format.format(value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Thanh Progress Bar tùy chỉnh
                Stack(
                  children: [
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                    ),
                    FractionallySizedBox(
                      widthFactor: percent, // Chiều dài thanh dựa trên %
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: itemColor,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [BoxShadow(color: itemColor.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2))]
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${(percent * 100).toStringAsFixed(1)}%",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                )
              ],
            );
          },
        ),
      ],
    );
  }

  // Logic vẽ biểu đồ Donut
  List<PieChartSectionData> _showingSections(Map<String, double> data, double total) {
    final List<Color> palette = [
      const Color(0xFF4E54C8), const Color(0xFFFF7E5F), const Color(0xFF00B09B),
      const Color(0xFFFC466B), const Color(0xFFFFD200), const Color(0xFF8E2DE2)
    ];
    
    int i = 0;
    return data.entries.map((entry) {
      final isTouched = (i == touchedIndex);
      final double radius = isTouched ? 25.0 : 20.0; // Biểu đồ mỏng
      
      var section = PieChartSectionData(
        color: palette[i % palette.length],
        value: entry.value,
        title: '', // Không hiện text trên biểu đồ cho đỡ rối
        radius: radius,
      );
      i++;
      return section;
    }).toList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.pie_chart_outline, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text("Chưa có dữ liệu", style: TextStyle(color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}