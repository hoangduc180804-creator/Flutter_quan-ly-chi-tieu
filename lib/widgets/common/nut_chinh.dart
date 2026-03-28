import 'package:flutter/material.dart';

class BottomNavPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF1A2429) // Màu xám đen cùng tông nền
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 20);
    path.quadraticBezierTo(0, 0, 20, 0);
    
    double center = size.width / 2;
    double holeWidth = 70;

    path.lineTo(center - holeWidth, 0);
    path.cubicTo(center - holeWidth + 20, 0, center - holeWidth + 10, 42, center, 42);
    path.cubicTo(center + holeWidth - 10, 42, center + holeWidth - 20, 0, center + holeWidth, 0);

    path.lineTo(size.width - 20, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Đổ bóng màu Teal nhẹ cho hiện đại
    canvas.drawShadow(path, Colors.tealAccent.withOpacity(0.2), 15, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class NutChinh extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NutChinh({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 80),
              painter: BottomNavPainter(),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: SizedBox(
                height: 70,
                child: Row(
                  children: [
                    Expanded(child: _buildItem(0, Icons.home_rounded, "Trang chủ")),
                    Expanded(child: _buildItem(1, Icons.account_balance_wallet_rounded, "Chi tiêu")),
                    const SizedBox(width: 80), 
                    Expanded(child: _buildItem(3, Icons.analytics_outlined, "Thử thách")),
                    Expanded(child: _buildItem(4, Icons.settings_rounded, "Cài đặt")),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 10, 
            child: _buildCenterButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(int index, IconData icon, String label) {
    bool isSelected = currentIndex == index;
    // Màu xanh Teal cho item được chọn
    Color activeColor = const Color(0xFF26A69A); 
    
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? activeColor : Colors.white38, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? activeColor : Colors.white38,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () => onTap(2),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF26A69A), Color(0xFF00796B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF26A69A).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: const Icon(Icons.add_rounded, size: 38, color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            "Thêm",
            style: TextStyle(
              fontSize: 11, 
              color: Colors.white70, 
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none
            ),
          ),
        ],
      ),
    );
  }
}