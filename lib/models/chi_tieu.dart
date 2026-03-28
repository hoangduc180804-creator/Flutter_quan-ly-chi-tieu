import 'package:cloud_firestore/cloud_firestore.dart';

class ChiTieu {
  String? id;
  final String ten;
  final double soTien;
  final DateTime thoiGian;

  ChiTieu({
    this.id,
    required this.ten,
    required this.soTien,
    required this.thoiGian,
  });

  // Chuyển đổi từ dữ liệu Firebase sang Object Flutter
  factory ChiTieu.fromFirestore(String id, Map<String, dynamic> data) {
    return ChiTieu(
      id: id,
      ten: data['ten'] ?? '',
      soTien: (data['soTien'] ?? 0).toDouble(),
      // Kiểm tra an toàn cho thoiGian
      thoiGian: data['thoiGian'] != null 
          ? (data['thoiGian'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ten': ten,
      'soTien': soTien,
      'thoiGian': thoiGian,
    };
  }
}