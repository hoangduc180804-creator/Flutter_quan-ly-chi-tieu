import 'package:flutter/material.dart';

class IPhone12Frame extends StatelessWidget {
  final Widget child;

  const IPhone12Frame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Kích thước mô phỏng (tương đối theo tỉ lệ iPhone 12/13/14)
    const double phoneWidth = 360;
    const double phoneHeight = 740;
    const double borderWidth = 3.0; // Viền kim loại
    const double bezelWidth = 10.0; // Viền đen màn hình

    return Center(
      child: SizedBox(
        width: phoneWidth + 10, // Cộng thêm không gian cho các nút bấm nhô ra
        height: phoneHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. CÁC NÚT VẬT LÝ (Nằm lớp dưới cùng để nhô ra ngoài khung)
            _buildPhysicalButtons(phoneWidth, phoneHeight),

            // 2. KHUNG MÁY (CHASSIS)
            Container(
              width: phoneWidth,
              height: phoneHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF242930), // Màu khung viền (Graphite/Black)
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: const Color(0xFF3A3A3C), // Hiệu ứng ánh kim nhẹ ở viền
                  width: borderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 50,
                    spreadRadius: 5,
                    offset: const Offset(0, 20), // Đổ bóng sâu tạo cảm giác 3D
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(bezelWidth), // Viền đen màn hình
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40), // Bo góc màn hình hiển thị
                  child: Stack(
                    children: [
                      // A. MÀN HÌNH ỨNG DỤNG (Nằm dưới cùng để tràn viền)
                      Positioned.fill(
                        child: Container(
                          color: Colors.white, // Màu nền mặc định nếu child trong suốt
                          child: child, 
                        ),
                      ),

                      // B. THANH TRẠNG THÁI (Status Bar + Notch)
                      _buildStatusBarAndNotch(),

                      // C. THANH HOME (Home Indicator)
                      _buildHomeIndicator(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CÁC WIDGET CON ---

  Widget _buildPhysicalButtons(double phoneWidth, double phoneHeight) {
    // Vị trí tương đối của các nút
    return Stack(
      children: [
        // Nút gạt rung (Mute Switch) - Bên trái trên cùng
        Positioned(
          left: 0,
          top: 100,
          child: _buttonShape(width: 4, height: 24, color: const Color(0xFF1C1C1E)),
        ),
        // Nút Tăng âm lượng - Bên trái
        Positioned(
          left: 0,
          top: 150,
          child: _buttonShape(width: 4, height: 45, color: const Color(0xFF2C2C2E)),
        ),
        // Nút Giảm âm lượng - Bên trái
        Positioned(
          left: 0,
          top: 210,
          child: _buttonShape(width: 4, height: 45, color: const Color(0xFF2C2C2E)),
        ),
        // Nút Nguồn (Power) - Bên phải (Lớn hơn chút)
        Positioned(
          right: 0,
          top: 160,
          child: _buttonShape(width: 4, height: 80, color: const Color(0xFF2C2C2E)),
        ),
      ],
    );
  }

  Widget _buttonShape({required double width, required double height, required Color color}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 2,
            offset: const Offset(0, 1),
          )
        ],
      ),
    );
  }

  Widget _buildStatusBarAndNotch() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 44, // Chiều cao chuẩn status bar iPhone
      child: Material(
        // QUAN TRỌNG: Material giúp sửa lỗi gạch chân vàng và hiển thị text đẹp
        type: MaterialType.transparency,
        child: Stack(
          children: [
            // 1. Giờ và Icons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Giờ
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        "9:41",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'SF Pro Text', // Nếu có font này thì càng đẹp
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  // Icons (Sóng, Wifi, Pin)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.signal_cellular_alt_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        const Icon(Icons.wifi_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        _buildBatteryIcon(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Tai thỏ (Notch)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 160,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Loa thoại
                    Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Camera trước (chấm nhỏ mờ)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        shape: BoxShape.circle,
                        boxShadow: [
                           BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 2)
                        ]
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryIcon() {
    return SizedBox(
      width: 24,
      height: 11,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(2),
            width: 18,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 2,
              height: 4,
              margin: const EdgeInsets.only(right: 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.horizontal(right: Radius.circular(1)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHomeIndicator() {
    return Positioned(
      bottom: 8,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 135,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white, // Hoặc Colors.black tuỳ vào nền app của bạn
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
              )
            ]
          ),
        ),
      ),
    );
  }
}